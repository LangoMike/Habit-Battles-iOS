//
//  CalendarService.swift
//  Habit-Battles
//
//  Service for calendar data and check-ins
//

import Foundation
import Supabase

struct CalendarCheckIn: Identifiable {
    let id: String
    let habitName: String
    let checkinDate: String
    let createdAt: Date?
}

/// Service for managing calendar data
@MainActor
class CalendarService: ObservableObject {
    @Published var checkins: [CalendarCheckIn] = []
    @Published var isLoading = false
    
    private let supabase = SupabaseManager.shared.client
    
    /// Fetch check-ins for the calendar view
    func fetchCheckins(
        userId: String,
        viewMode: CalendarViewMode,
        currentDate: Date,
        timezone: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Calculate date range based on view mode
        let (startDate, endDate) = getDateRange(for: viewMode, currentDate: currentDate, timezone: timezone)
        
        let startISO = formatDate(startDate)
        let endISO = formatDate(endDate)
        
        // Fetch check-ins for the date range
        let { data: checkinData, error: checkinError } = try await supabase
            .from("checkins")
            .select("habit_id, checkin_date, created_at")
            .eq("user_id", value: userId)
            .gte("checkin_date", value: startISO)
            .lte("checkin_date", value: endISO)
            .order("checkin_date", ascending: false)
            .execute()
        
        if let checkinError = checkinError {
            throw checkinError
        }
        
        guard let checkinData = checkinData, !checkinData.isEmpty else {
            self.checkins = []
            return
        }
        
        // Get habit IDs
        let habitIds = Array(Set(checkinData.compactMap { $0["habit_id"] as? String }))
        
        guard !habitIds.isEmpty else {
            self.checkins = []
            return
        }
        
        // Fetch habit names
        let { data: habitData, error: habitError } = try await supabase
            .from("habits")
            .select("id, name")
            .in("id", values: habitIds)
            .execute()
        
        if let habitError = habitError {
            throw habitError
        }
        
        // Create habit map
        var habitMap: [String: String] = [:]
        (habitData ?? []).forEach { habit in
            if let id = habit["id"] as? String,
               let name = habit["name"] as? String {
                habitMap[id] = name
            }
        }
        
        // Combine check-ins with habit names
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        self.checkins = checkinData.compactMap { checkin in
            guard let habitId = checkin["habit_id"] as? String,
                  let checkinDate = checkin["checkin_date"] as? String,
                  let habitName = habitMap[habitId] else {
                return nil
            }
            
            var createdAt: Date?
            if let createdAtStr = checkin["created_at"] as? String {
                createdAt = ISO8601DateFormatter().date(from: createdAtStr)
            }
            
            return CalendarCheckIn(
                id: UUID().uuidString,
                habitName: habitName,
                checkinDate: checkinDate,
                createdAt: createdAt
            )
        }
    }
    
    /// Get check-ins for a specific date
    func getCheckins(for date: Date) -> [CalendarCheckIn] {
        let dateStr = formatDate(date)
        return checkins.filter { $0.checkinDate == dateStr }
    }
    
    /// Get completion count for a date
    func getCompletionCount(for date: Date) -> Int {
        let dateStr = formatDate(date)
        return checkins.filter { $0.checkinDate == dateStr }.count
    }
    
    /// Get square color based on completion count
    func getSquareColor(count: Int) -> (background: Color, border: Color) {
        switch count {
        case 0:
            return (Color.gray.opacity(0.3), Color.gray.opacity(0.5))
        case 1:
            return (Color.green.opacity(0.7), Color.green.opacity(0.8))
        case 2...3:
            return (Color.green.opacity(0.8), Color.green.opacity(0.9))
        case 4...5:
            return (Color.teal.opacity(0.8), Color.teal.opacity(0.9))
        default:
            return (Color.teal.opacity(0.9), Color.teal)
        }
    }
    
    // MARK: - Helper Functions
    
    private func getDateRange(
        for viewMode: CalendarViewMode,
        currentDate: Date,
        timezone: String
    ) -> (start: Date, end: Date) {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        
        switch viewMode {
        case .week:
            // Monday to Sunday
            let weekday = calendar.component(.weekday, from: currentDate)
            let daysFromMonday = weekday == 1 ? 6 : weekday - 2
            
            let start = calendar.date(byAdding: .day, value: -daysFromMonday, to: currentDate) ?? currentDate
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
            
            return (start, end)
            
        case .month:
            // First day of month to last day
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            let start = calendar.date(from: components) ?? currentDate
            
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            let end = calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? start
            
            // Include padding days for full weeks
            let firstWeekday = calendar.component(.weekday, from: start)
            let daysFromPrevMonth = firstWeekday == 1 ? 6 : firstWeekday - 2
            let paddedStart = calendar.date(byAdding: .day, value: -daysFromPrevMonth, to: start) ?? start
            
            // End on last day of last week
            let lastWeekday = calendar.component(.weekday, from: end)
            let daysToNextMonth = lastWeekday == 1 ? 0 : 8 - lastWeekday
            let paddedEnd = calendar.date(byAdding: .day, value: daysToNextMonth, to: end) ?? end
            
            return (paddedStart, paddedEnd)
            
        case .year:
            // January 1 to December 31
            let components = calendar.dateComponents([.year], from: currentDate)
            let start = calendar.date(from: DateComponents(year: components.year, month: 1, day: 1)) ?? currentDate
            let end = calendar.date(from: DateComponents(year: components.year, month: 12, day: 31)) ?? currentDate
            
            return (start, end)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

