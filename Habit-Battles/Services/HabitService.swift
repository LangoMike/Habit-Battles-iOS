//
//  HabitService.swift
//  Habit-Battles
//
//  Service for managing habits and check-ins
//

import Foundation
import Supabase

/// Service for handling habit operations (CRUD + check-ins)
@MainActor
class HabitService: ObservableObject {
    @Published var habits: [HabitWithProgress] = []
    @Published var isLoading = false
    
    private let supabase = SupabaseManager.shared.client
    
    /// Fetch all habits for the current user with progress tracking
    func fetchHabits(userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Get current date in user's timezone
        let today = getTodayDate(timezone: timezone)
        let (weekStart, weekEnd) = getWeekBounds(timezone: timezone)
        
        // Fetch all habits for user
        let { data: habitsData, error: habitsError } = try await supabase
            .from("habits")
            .select("*")
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
        
        if let habitsError = habitsError {
            throw habitsError
        }
        
        guard let habitsData = habitsData else {
            self.habits = []
            return
        }
        
        // Decode habits
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let allHabits = try habitsData.map { try decoder.decode(Habit.self, from: $0) }
        
        // Fetch check-ins for this week
        let habitIds = allHabits.map { $0.id }
        guard !habitIds.isEmpty else {
            self.habits = allHabits.map { HabitWithProgress(habit: $0, doneToday: false, doneThisWeek: 0) }
            return
        }
        
        let { data: weekCheckins, error: weekError } = try await supabase
            .from("checkins")
            .select("habit_id, checkin_date")
            .eq("user_id", value: userId)
            .in("habit_id", values: habitIds)
            .gte("checkin_date", value: weekStart)
            .lte("checkin_date", value: weekEnd)
            .execute()
        
        // Fetch today's check-ins
        let { data: todayCheckins } = try await supabase
            .from("checkins")
            .select("habit_id")
            .eq("user_id", value: userId)
            .in("habit_id", values: habitIds)
            .eq("checkin_date", value: today)
            .execute()
        
        // Process check-ins into progress data
        let doneTodaySet = Set((todayCheckins ?? []).compactMap { $0["habit_id"] as? String })
        var weekCounts: [String: Int] = [:]
        
        (weekCheckins ?? []).forEach { checkin in
            if let habitId = checkin["habit_id"] as? String {
                weekCounts[habitId, default: 0] += 1
            }
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
        
        let newHabit = Habit(
            id: UUID().uuidString,
            userId: userId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            targetPerWeek: targetPerWeek,
            schedule: "daily",
            timezone: timezone,
            createdAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let habitJSON = try encoder.encode(newHabit)
        
        let { error } = try await supabase
            .from("habits")
            .insert(habitJSON)
            .execute()
        
        if let error = error {
            throw error
        }
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
        
        return newHabit
    }
    
    /// Update an existing habit
    func updateHabit(_ habit: Habit, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let habitJSON = try encoder.encode(habit)
        
        let { error } = try await supabase
            .from("habits")
            .update(habitJSON)
            .eq("id", value: habit.id)
            .execute()
        
        if let error = error {
            throw error
        }
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
    }
    
    /// Delete a habit
    func deleteHabit(habitId: String, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let { error } = try await supabase
            .from("habits")
            .delete()
            .eq("id", value: habitId)
            .execute()
        
        if let error = error {
            throw error
        }
        
        // Refresh habits list
        try await fetchHabits(userId: userId, timezone: timezone)
    }
    
    /// Check in for a habit (mark as done today)
    func checkIn(habitId: String, userId: String, timezone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let today = getTodayDate(timezone: timezone)
        
        // Check if already checked in today
        let { data: existing, error: checkError } = try await supabase
            .from("checkins")
            .select("id")
            .eq("user_id", value: userId)
            .eq("habit_id", value: habitId)
            .eq("checkin_date", value: today)
            .maybeSingle()
            .execute()
        
        if checkError != nil && !(checkError?.localizedDescription.contains("PGRST116") ?? false) {
            // PGRST116 is "not found" which is fine, means no duplicate
            throw checkError!
        }
        
        if existing != nil {
            // Already checked in today
            throw NSError(domain: "HabitService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Already checked in for today"])
        }
        
        // Create check-in
        let checkIn = CheckIn(
            id: UUID().uuidString,
            userId: userId,
            habitId: habitId,
            checkinDate: today,
            createdAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let checkInJSON = try encoder.encode(checkIn)
        
        let { error } = try await supabase
            .from("checkins")
            .insert(checkInJSON)
            .execute()
        
        if let error = error {
            throw error
        }
        
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

