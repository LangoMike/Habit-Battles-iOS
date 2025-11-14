//
//  CalendarComponents.swift
//  Habit-Battles
//
//  Calendar UI components
//

import SwiftUI

/// Calendar navigation header
struct CalendarNavigationView: View {
    @Binding var currentDate: Date
    let viewMode: CalendarViewMode
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Text(getViewTitle())
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func getViewTitle() -> String {
        let formatter = DateFormatter()
        
        switch viewMode {
        case .week:
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: currentDate)
            let daysFromMonday = weekday == 1 ? 6 : weekday - 2
            let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: currentDate) ?? currentDate
            let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
            
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: monday)) - \(formatter.string(from: sunday))"
            
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
            
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentDate)
        }
    }
}

/// Calendar grid view
struct CalendarGridView: View {
    let viewMode: CalendarViewMode
    let currentDate: Date
    @ObservedObject var calendarService: CalendarService
    let onDateTap: (Date) -> Void
    
    var body: some View {
        let days = getDays()
        
        VStack(spacing: 0) {
            // Weekday headers (for week and month views)
            if viewMode == .week || viewMode == .month {
                HStack(spacing: 0) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Calendar grid
            if viewMode == .year {
                GeometryReader { geometry in
                    let spacing: CGFloat = 2
                    let desiredTile: CGFloat = 7
                    let availableWidth = max(geometry.size.width, 1)
                    let tentativeColumns = max(Int((availableWidth + spacing) / (desiredTile + spacing)), 12)
                    let tileSizeNumerator = availableWidth - CGFloat(tentativeColumns - 1) * spacing
                    let tileSize = max(min(tileSizeNumerator / CGFloat(tentativeColumns), 9), 4)
                    let columns = Array(repeating: GridItem(.fixed(tileSize), spacing: spacing), count: tentativeColumns)
                    let rows = ceil(Double(days.count) / Double(tentativeColumns))
                    
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(days, id: \.self) { date in
                            CalendarDaySquare(
                                date: date,
                                count: calendarService.getCompletionCount(for: date),
                                isToday: Calendar.current.isDateInToday(date),
                                isCurrentPeriod: true,
                                viewMode: viewMode,
                                customSize: tileSize,
                                onTap: { onDateTap(date) }
                            )
                        }
                    }
                    .frame(height: CGFloat(rows) * (tileSize + spacing))
                }
                .frame(minHeight: 240)
            } else {
                // Week/Month view: 7 columns
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(days, id: \.self) { date in
                        CalendarDaySquare(
                            date: date,
                            count: calendarService.getCompletionCount(for: date),
                            isToday: Calendar.current.isDateInToday(date),
                            isCurrentPeriod: isInCurrentPeriod(date),
                            viewMode: viewMode,
                            onTap: { onDateTap(date) }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getDays() -> [Date] {
        let calendar = Calendar.current
        var days: [Date] = []
        
        switch viewMode {
        case .week:
            let weekday = calendar.component(.weekday, from: currentDate)
            let daysFromMonday = weekday == 1 ? 6 : weekday - 2
            let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: currentDate) ?? currentDate
            
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: monday) {
                    days.append(date)
                }
            }
            
        case .month:
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            guard let start = calendar.date(from: components) else { return [] }
            
            let firstWeekday = calendar.component(.weekday, from: start)
            let daysFromPrevMonth = firstWeekday == 1 ? 6 : firstWeekday - 2
            let paddedStart = calendar.date(byAdding: .day, value: -daysFromPrevMonth, to: start) ?? start
            
            for i in 0..<42 { // 6 weeks
                if let date = calendar.date(byAdding: .day, value: i, to: paddedStart) {
                    days.append(date)
                }
            }
            
        case .year:
            let components = calendar.dateComponents([.year], from: currentDate)
            guard let yearStart = calendar.date(from: DateComponents(year: components.year, month: 1, day: 1)) else {
                return []
            }
            
            for i in 0..<365 {
                if let date = calendar.date(byAdding: .day, value: i, to: yearStart) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    private func isInCurrentPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        switch viewMode {
        case .week:
            return true // All days shown are in current week
        case .month:
            return calendar.component(.month, from: date) == calendar.component(.month, from: currentDate)
        case .year:
            return calendar.component(.year, from: date) == calendar.component(.year, from: currentDate)
        }
    }
}

/// Individual calendar day square
struct CalendarDaySquare: View {
    let date: Date
    let count: Int
    let isToday: Bool
    let isCurrentPeriod: Bool
    let viewMode: CalendarViewMode
    let customSize: CGFloat?
    let onTap: () -> Void
    
    init(
        date: Date,
        count: Int,
        isToday: Bool,
        isCurrentPeriod: Bool,
        viewMode: CalendarViewMode,
        customSize: CGFloat? = nil,
        onTap: @escaping () -> Void
    ) {
        self.date = date
        self.count = count
        self.isToday = isToday
        self.isCurrentPeriod = isCurrentPeriod
        self.viewMode = viewMode
        self.customSize = customSize
        self.onTap = onTap
    }
    
    @StateObject private var calendarService = CalendarService()
    
    var body: some View {
        let colors = calendarService.getSquareColor(count: count)
        let defaultSize: CGFloat = viewMode == .year ? 6 : 40
        let size = customSize ?? defaultSize
        
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: viewMode == .year ? 1 : 4)
                    .fill(colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: viewMode == .year ? 1 : 4)
                            .stroke(colors.border, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: viewMode == .year ? 1 : 4)
                            .stroke(isToday ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .opacity(isCurrentPeriod ? 1.0 : 0.3)
                
                if viewMode != .year && count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

/// Calendar stats summary
struct CalendarStatsView: View {
    let stats: QuotaStats
    let streakData: StreakData
    
    var body: some View {
        HStack(spacing: 12) {
            // Weekly Quotas Met
            StatMiniCard(
                value: "\(stats.weeklyQuotasMet)/\(stats.totalHabits)",
                label: "Weekly Quotas",
                color: .red
            )
            
            // Total Check-ins
            StatMiniCard(
                value: "\(stats.totalCheckins)",
                label: "Total Check-ins",
                color: .red
            )
            
            // Active Habits
            StatMiniCard(
                value: "\(stats.totalHabits)",
                label: "Active Habits",
                color: .red
            )
            
            // Streak
            StatMiniCard(
                value: "\(streakData.dailyStreak)",
                label: "Day Streak",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

struct StatMiniCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [color.opacity(0.2), color.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(8)
    }
}

/// Calendar date detail sheet
struct CalendarDateDetailView: View {
    let date: Date
    let checkins: [CalendarCheckIn]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(formatDate(date))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom)
                    
                    if checkins.isEmpty {
                        Text("No habits completed on this day.")
                            .font(.body)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(checkins) { checkin in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(checkin.habitName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if let createdAt = checkin.createdAt {
                                        Text("Checked in at \(formatTime(createdAt))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("Completed")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Check-ins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView()
        .environmentObject(AuthService())
}

