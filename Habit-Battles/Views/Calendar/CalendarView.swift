//
//  CalendarView.swift
//  Habit-Battles
//
//  Calendar view with heatmap visualization
//

import SwiftUI
internal import Auth

enum CalendarViewMode: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct CalendarView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var calendarService = CalendarService()
    @StateObject private var statsService = StatsService()
    
    @State private var viewMode: CalendarViewMode = .month
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var selectedCheckins: [CalendarCheckIn] = []
    @State private var stats: QuotaStats?
    @State private var streakData: StreakData?
    @State private var isLoading = true
    
    private var timezone: String {
        TimeZone.current.identifier
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with view mode selector
                HStack {
                    Text("Activity Calendar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.horizontal)
                
                // Stats Summary
                if let stats = stats, let streakData = streakData {
                    CalendarStatsView(stats: stats, streakData: streakData)
                }
                
                // Calendar Navigation
                CalendarNavigationView(
                    currentDate: $currentDate,
                    viewMode: viewMode,
                    onPrevious: { navigateDate(direction: .previous) },
                    onNext: { navigateDate(direction: .next) }
                )
                
                // Calendar Grid
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    CalendarGridView(
                        viewMode: viewMode,
                        currentDate: currentDate,
                        calendarService: calendarService,
                        onDateTap: { date in
                            selectedDate = date
                            selectedCheckins = calendarService.getCheckins(for: date)
                        }
                    )
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(item: Binding(
            get: { selectedDate.map { CalendarDateItem(date: $0) } },
            set: { selectedDate = $0?.date }
        )) { item in
            CalendarDateDetailView(
                date: item.date,
                checkins: selectedCheckins
            )
        }
        .task {
            await loadCalendarData()
        }
        .onChange(of: viewMode) { _ in
            Task {
                await loadCalendarData()
            }
        }
        .onChange(of: currentDate) { _ in
            Task {
                await loadCalendarData()
            }
        }
    }
    
    /// Load calendar data
    private func loadCalendarData() async {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        
        isLoading = true
        
        // Load stats and streaks
        async let statsTask = statsService.getQuotaStats(userId: userId, timezone: timezone)
        async let streakTask = statsService.getStreakData(userId: userId)
        async let calendarTask = calendarService.fetchCheckins(
            userId: userId,
            viewMode: viewMode,
            currentDate: currentDate,
            timezone: timezone
        )
        
        do {
            stats = try await statsTask
            streakData = try await streakTask
            _ = try await calendarTask
        } catch {
            print("Failed to load calendar data: \(error)")
        }
        
        isLoading = false
    }
    
    /// Navigate to previous/next period
    private func navigateDate(direction: NavigationDirection) {
        let calendar = Calendar.current
        var newDate = currentDate
        
        switch viewMode {
        case .week:
            newDate = calendar.date(byAdding: .day, value: direction == .next ? 7 : -7, to: currentDate) ?? currentDate
        case .month:
            newDate = calendar.date(byAdding: .month, value: direction == .next ? 1 : -1, to: currentDate) ?? currentDate
        case .year:
            newDate = calendar.date(byAdding: .year, value: direction == .next ? 1 : -1, to: currentDate) ?? currentDate
        }
        
        currentDate = newDate
    }
}

enum NavigationDirection {
    case previous
    case next
}

/// Identifiable wrapper for Date to use in sheet
struct CalendarDateItem: Identifiable {
    let id = UUID()
    let date: Date
}

#Preview {
    CalendarView()
        .environmentObject(AuthService())
}



