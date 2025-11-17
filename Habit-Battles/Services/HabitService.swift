//
//  HabitService.swift
//  Habit-Battles
//
//  Service for managing habits and check-ins
//

import Foundation
import Combine
import Supabase

/// Service for handling habit operations (CRUD + check-ins)
@MainActor
class HabitService: ObservableObject {
    @Published var habits: [HabitWithProgress] = []
    @Published var isLoading = false
    
    private let supabase = SupabaseManager.shared.client
#if DEBUG
    private var debugHabits: [HabitWithProgress] = []
#endif
    
    /// Fetch all habits for the current user with progress tracking
    func fetchHabits(userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            if debugHabits.isEmpty {
                debugHabits = DebugAuthDefaults.sampleHabits()
            }
            self.habits = debugHabits
            return
        }
#endif
        
        // Get current date in user's timezone
        let today = getTodayDate(timezone: timezone)
        let (weekStart, weekEnd) = getWeekBounds(timezone: timezone)
        
        // Fetch all habits for user
        // Pull all habit records for the user
        let response: Supabase.PostgrestResponse<[Habit]> = try await supabase
            .from("habits")
            .select("*")
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
        
        let allHabits = response.value
        
        // Fetch check-ins for this week
        let habitIds = allHabits.map { $0.id }
        guard !habitIds.isEmpty else {
            self.habits = allHabits.map { HabitWithProgress(habit: $0, doneToday: false, doneThisWeek: 0) }
            return
        }
        
        struct CheckInResponse: Codable {
            let habit_id: String
            let checkin_date: String
        }
        
        // Gather this week's check-ins for progress tracking
        let weekResponse: Supabase.PostgrestResponse<[CheckInResponse]> = try await supabase
            .from("checkins")
            .select("habit_id, checkin_date")
            .eq("user_id", value: userId)
            .in("habit_id", values: habitIds)
            .gte("checkin_date", value: weekStart)
            .lte("checkin_date", value: weekEnd)
            .execute()
        
        // Fetch today's check-ins
        struct TodayCheckInResponse: Codable {
            let habit_id: String
        }
        
        let todayResponse: Supabase.PostgrestResponse<[TodayCheckInResponse]> = try await supabase
            .from("checkins")
            .select("habit_id")
            .eq("user_id", value: userId)
            .in("habit_id", values: habitIds)
            .eq("checkin_date", value: today)
            .execute()
        
        // Decode responses directly from Supabase helper
        let weekCheckins = weekResponse.value
        let todayCheckins = todayResponse.value
        
        // Process check-ins into progress data
        let doneTodaySet = Set(todayCheckins.map { $0.habit_id })
        var weekCounts: [String: Int] = [:]
        
        weekCheckins.forEach { checkin in
            weekCounts[checkin.habit_id, default: 0] += 1
        }
        
        // Combine habits with progress
        let habitsWithProgress = allHabits.map { habit in
            HabitWithProgress(
                habit: habit,
                doneToday: doneTodaySet.contains(habit.id),
                doneThisWeek: weekCounts[habit.id] ?? 0
            )
        }
        
        self.habits = habitsWithProgress
    }
    
    /// Create a new habit
    func createHabit(userId: String, name: String, targetPerWeek: Int, timezone: String) async throws -> Habit {
        isLoading = true
        defer { isLoading = false }
        
        // Validate target
        guard targetPerWeek >= 1 && targetPerWeek <= 7 else {
            throw NSError(domain: "HabitService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Target per week must be between 1 and 7"])
        }
        
        let habitId = UUID().uuidString
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            let newHabit = Habit(
                id: habitId,
                userId: userId,
                name: trimmedName,
                targetPerWeek: targetPerWeek,
                schedule: "daily",
                timezone: timezone,
                createdAt: Date()
            )
            let newHabitWithProgress = HabitWithProgress(
                habit: newHabit,
                doneToday: false,
                doneThisWeek: 0
            )
            debugHabits.append(newHabitWithProgress)
            self.habits = debugHabits
            return newHabit
        }
#endif
        
        // Create habit payload (exclude createdAt if DB auto-generates it)
        struct HabitInsert: Codable {
            let id: String
            let user_id: String
            let name: String
            let target_per_week: Int
            let schedule: String
            let timezone: String
        }
        
        let habitPayload = HabitInsert(
            id: habitId,
            user_id: userId,
            name: trimmedName,
            target_per_week: targetPerWeek,
            schedule: "daily",
            timezone: timezone
        )
        
        // Insert habit directly - Supabase SDK handles encoding
        try await supabase
            .from("habits")
            .insert(habitPayload)
            .execute()
        
        // Create Habit object for return value
        let newHabit = Habit(
            id: habitId,
            userId: userId,
            name: trimmedName,
            targetPerWeek: targetPerWeek,
            schedule: "daily",
            timezone: timezone,
            createdAt: Date()
        )
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
        
        return newHabit
    }
    
    /// Update an existing habit
    func updateHabit(_ habit: Habit, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            if let index = debugHabits.firstIndex(where: { $0.id == habit.id }) {
                let existing = debugHabits[index]
                let updated = HabitWithProgress(
                    habit: habit,
                    doneToday: existing.doneToday,
                    doneThisWeek: existing.doneThisWeek
                )
                debugHabits[index] = updated
                self.habits = debugHabits
            }
            return
        }
#endif
        
        // Create update payload excluding fields that shouldn't change
        struct HabitUpdate: Codable {
            let name: String
            let target_per_week: Int
            let schedule: String
            let timezone: String
        }
        
        let updatePayload = HabitUpdate(
            name: habit.name,
            target_per_week: habit.targetPerWeek,
            schedule: habit.schedule,
            timezone: habit.timezone
        )
        
        // Update habit directly - Supabase SDK handles encoding
        try await supabase
            .from("habits")
            .update(updatePayload)
            .eq("id", value: habit.id)
            .execute()
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
    }
    
    /// Delete a habit
    func deleteHabit(habitId: String, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            debugHabits.removeAll { $0.id == habitId }
            self.habits = debugHabits
            return
        }
#endif
        
        try await supabase
            .from("habits")
            .delete()
            .eq("id", value: habitId)
            .execute()
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
    }
    
    /// Check in for a habit (mark as done today)
    func checkIn(habitId: String, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let today = getTodayDate(timezone: timezone)
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            if let index = debugHabits.firstIndex(where: { $0.id == habitId }) {
                var habitProgress = debugHabits[index]
                if habitProgress.doneToday {
                    throw NSError(domain: "HabitService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Already checked in for today"])
                }
                habitProgress.doneToday = true
                habitProgress.doneThisWeek += 1
                debugHabits[index] = habitProgress
                self.habits = debugHabits
            }
            return
        }
#endif
        
        // Check if already checked in today
        struct ExistingCheckIn: Codable {
            let id: String
        }
        
        do {
            let existingResponse: Supabase.PostgrestResponse<[ExistingCheckIn]> = try await supabase
                .from("checkins")
                .select("id")
                .eq("user_id", value: userId)
                .eq("habit_id", value: habitId)
                .eq("checkin_date", value: today)
                .limit(1)
                .execute()
            
            // If we get data, it means already checked in
            if existingResponse.value.first != nil {
                throw NSError(domain: "HabitService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Already checked in for today"])
            }
        } catch {
            // If error is "not found", that's fine - means no duplicate
            // Otherwise, rethrow
            if !error.localizedDescription.contains("PGRST116") {
                throw error
            }
        }
        
        // Create check-in payload (exclude createdAt if DB auto-generates it)
        struct CheckInInsert: Codable {
            let id: String
            let user_id: String
            let habit_id: String
            let checkin_date: String
        }
        
        let checkInPayload = CheckInInsert(
            id: UUID().uuidString,
            user_id: userId,
            habit_id: habitId,
            checkin_date: today
        )
        
        // Insert check-in directly - Supabase SDK handles encoding
        try await supabase
            .from("checkins")
            .insert(checkInPayload)
            .execute()
        
        // Refresh habits list to update progress
        try await fetchHabits(userId: userId, timezone: timezone)
    }
    
    /// Get today's date in ISO format (YYYY-MM-DD) for the given timezone
    private func getTodayDate(timezone: String) -> String {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        guard let date = calendar.date(from: components) else {
            // Fallback to UTC
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
            return formatter.string(from: now)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: date)
    }
    
    /// Get week bounds (Monday to Sunday) for the given timezone
    private func getWeekBounds(timezone: String) -> (start: String, end: String) {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        // Convert Sunday=1 to Monday=0, Tuesday=1, etc.
        let daysSinceMonday = (weekday + 5) % 7
        
        guard let weekStart = calendar.date(byAdding: .day, value: -daysSinceMonday, to: now),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            // Fallback
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
            return (formatter.string(from: now), formatter.string(from: now))
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        return (formatter.string(from: weekStart), formatter.string(from: weekEnd))
    }
}

