//
//  StatsService.swift
//  Habit-Battles
//
//  Service for calculating statistics and streaks
//

import Foundation
import Combine
import Supabase

/// Statistics data structure matching webapp
struct QuotaStats {
    let weeklyQuotasMet: Int
    let totalCheckins: Int
    let totalHabits: Int
    let currentWeekProgress: [HabitProgress]
}

struct HabitProgress {
    let habitId: String
    let habitName: String
    let target: Int
    let completed: Int
    let isMet: Bool
}

/// Streak data structure matching webapp
struct StreakData {
    let dailyStreak: Int
    let weeklyStreak: Int
    let lastCheckinDate: String?
}

/// Service for calculating user statistics
@MainActor
class StatsService: ObservableObject {
    private let supabase = SupabaseManager.shared.client
    
    /// Get quota statistics for the current week
    func getQuotaStats(userId: String, timezone: String) async throws -> QuotaStats {
        // Get current week dates (Monday to Sunday)
        let (weekStart, weekEnd) = getWeekBounds(timezone: timezone)
        
        // Get all user's habits
        struct HabitInfo: Codable {
            let id: String
            let name: String
            let target_per_week: Int
        }
        
        let decoder = JSONDecoder()
        let habitsResponse = try await supabase
            .from("habits")
            .select("id, name, target_per_week")
            .eq("user_id", value: userId)
            .execute()
        
        let habits = try decoder.decode([HabitInfo].self, from: habitsResponse.value)
        
        // Get check-ins for this week
        let habitIds = habits.map { $0.id }
        guard !habitIds.isEmpty else {
            return QuotaStats(
                weeklyQuotasMet: 0,
                totalCheckins: 0,
                totalHabits: habits.count,
                currentWeekProgress: []
            )
        }
        
        struct CheckInInfo: Codable {
            let habit_id: String
            let checkin_date: String
        }
        
        let weekResponse = try await supabase
            .from("checkins")
            .select("habit_id, checkin_date")
            .eq("user_id", value: userId)
            .in("habit_id", values: habitIds)
            .gte("checkin_date", value: weekStart)
            .lte("checkin_date", value: weekEnd)
            .execute()
        
        // Get total check-ins (all time)
        struct TotalCheckIn: Codable {
            let id: String
        }
        
        let totalResponse = try await supabase
            .from("checkins")
            .select("id")
            .eq("user_id", value: userId)
            .execute()
        
        let weekCheckins = try decoder.decode([CheckInInfo].self, from: weekResponse.value)
        let totalCheckins = try decoder.decode([TotalCheckIn].self, from: totalResponse.value)
        
        // Calculate weekly progress for each habit
        var habitProgress: [String: Int] = [:]
        weekCheckins.forEach { checkin in
            habitProgress[checkin.habit_id, default: 0] += 1
        }
        
        var weeklyQuotasMet = 0
        let currentWeekProgress = habits.map { habit in
            let completed = habitProgress[habit.id] ?? 0
            let isMet = completed >= habit.target_per_week
            if isMet { weeklyQuotasMet += 1 }
            
            return HabitProgress(
                habitId: habit.id,
                habitName: habit.name,
                target: habit.target_per_week,
                completed: completed,
                isMet: isMet
            )
        }
        
        return QuotaStats(
            weeklyQuotasMet: weeklyQuotasMet,
            totalCheckins: totalCheckins.count,
            totalHabits: habits.count,
            currentWeekProgress: currentWeekProgress
        )
    }
    
    /// Get streak data (daily and weekly)
    func getStreakData(userId: String) async throws -> StreakData {
        // Get all check-ins ordered by date
        struct CheckInDate: Codable {
            let checkin_date: String
        }
        
        let decoder = JSONDecoder()
        let response = try await supabase
            .from("checkins")
            .select("checkin_date")
            .eq("user_id", value: userId)
            .order("checkin_date", ascending: false)
            .execute()
        
        let checkinsData = try decoder.decode([CheckInDate].self, from: response.value)
        
        guard !checkinsData.isEmpty else {
            return StreakData(dailyStreak: 0, weeklyStreak: 0, lastCheckinDate: nil)
        }
        
        // Extract unique dates
        var uniqueDates: [String] = []
        var seenDates = Set<String>()
        checkinsData.forEach { checkin in
            if !seenDates.contains(checkin.checkin_date) {
                uniqueDates.append(checkin.checkin_date)
                seenDates.insert(checkin.checkin_date)
            }
        }
        
        uniqueDates.sort(by: >) // Sort descending
        
        guard !uniqueDates.isEmpty else {
            return StreakData(dailyStreak: 0, weeklyStreak: 0, lastCheckinDate: nil)
        }
        
        let today = getTodayDate()
        let yesterday = getYesterdayDate()
        
        // Calculate daily streak
        var dailyStreak = 0
        var currentDate = today
        
        if uniqueDates[0] == today || uniqueDates[0] == yesterday {
            for (index, checkinDate) in uniqueDates.enumerated() {
                if index == 0 {
                    if checkinDate == today {
                        currentDate = today
                        dailyStreak = 1
                    } else if checkinDate == yesterday {
                        currentDate = yesterday
                        dailyStreak = 1
                    } else {
                        break
                    }
                } else {
                    // Check if consecutive
                    let expectedDate = getPreviousDay(from: currentDate)
                    if checkinDate == expectedDate {
                        dailyStreak += 1
                        currentDate = checkinDate
                    } else {
                        break
                    }
                }
            }
        }
        
        // Calculate weekly streak
        var weeklyStreak = 0
        var weeksWithCheckins = Set<String>()
        
        uniqueDates.forEach { date in
            let weekStart = getWeekStart(for: date)
            weeksWithCheckins.insert(weekStart)
        }
        
        let weekStarts = Array(weeksWithCheckins).sorted(by: >)
        let currentWeekStart = getWeekStart(for: today)
        let lastWeekStart = getWeekStart(for: yesterday)
        
        if weekStarts.first == currentWeekStart || weekStarts.first == lastWeekStart {
            for (index, weekStart) in weekStarts.enumerated() {
                if index == 0 {
                    if weekStart == currentWeekStart || weekStart == lastWeekStart {
                        weeklyStreak = 1
                    } else {
                        break
                    }
                } else {
                    // Check if consecutive weeks
                    let expectedWeekStart = getPreviousWeek(from: weekStarts[index - 1])
                    if weekStart == expectedWeekStart {
                        weeklyStreak += 1
                    } else {
                        break
                    }
                }
            }
        }
        
        return StreakData(
            dailyStreak: dailyStreak,
            weeklyStreak: weeklyStreak,
            lastCheckinDate: uniqueDates.first
        )
    }
    
    // MARK: - Helper Functions
    
    private func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func getYesterdayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: yesterday)
    }
    
    private func getPreviousDay(from dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        return formatter.string(from: previousDay)
    }
    
    private func getWeekStart(for dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: date) else {
            return dateStr
        }
        
        return formatter.string(from: monday)
    }
    
    private func getPreviousWeek(from weekStartStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let weekStart = formatter.date(from: weekStartStr) else { return weekStartStr }
        let previousWeek = Calendar.current.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        return formatter.string(from: previousWeek)
    }
    
    private func getWeekBounds(timezone: String) -> (start: String, end: String) {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: now),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: timezone) ?? TimeZone.current
            return (formatter.string(from: now), formatter.string(from: now))
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        return (formatter.string(from: monday), formatter.string(from: sunday))
    }
}

