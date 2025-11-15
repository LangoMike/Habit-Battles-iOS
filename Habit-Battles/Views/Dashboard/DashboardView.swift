//
//  DashboardView.swift
//  Habit-Battles
//
//  Main dashboard with stats, streaks, and motivational content
//

import SwiftUI
internal import Auth

struct DashboardView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authService: AuthService
    @StateObject private var statsService = StatsService()
    @StateObject private var profileService = ProfileService()
    
    @State private var stats: QuotaStats?
    @State private var streakData: StreakData?
    @State private var username: String?
    @State private var isLoading = true
    
    @State private var quickActionSheet: QuickActionDestination?
    
    private var timezone: String {
        TimeZone.current.identifier
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                // Welcome Header
                VStack(spacing: 16) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    VStack(spacing: 4) {
                        Text("Welcome\(username != nil ? ", \(username!)" : "")!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Fight the old you. Build the new you.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                    Text("Ready to dominate your habits today?")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                // Motivational Quote
                MotivationalQuoteView()
                
                // Stats Cards
                if let stats = stats {
                    StatsCardsView(stats: stats)
                }
                
                // Streak Display
                if let streakData = streakData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Streaks")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        StreakDisplayView(streakData: streakData, variant: .dashboard)
                    }
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionCard(
                            icon: "list.bullet.clipboard",
                            title: "Manage Habits",
                            subtitle: "Create & track",
                            color: .red,
                            action: { handleQuickAction(.habits) }
                        )
                        
                        QuickActionCard(
                            icon: "calendar",
                            title: "View Calendar",
                            subtitle: "See your progress",
                            color: .red,
                            action: { handleQuickAction(.calendar) }
                        )
                        
                        QuickActionCard(
                            icon: "person.2.fill",
                            title: "Friends",
                            subtitle: "Connect & compete",
                            color: .red,
                            action: { handleQuickAction(.friends) }
                        )
                        
                        QuickActionCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Battles",
                            subtitle: "Join competitions",
                            color: .red,
                            action: { handleQuickAction(.battles) }
                        )
                    }
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
                .ignoresSafeArea()
            )
        }
        // Add gradient background
        .sheet(item: $quickActionSheet) { destination in
            switch destination {
            case .friends:
                PlaceholderDetailView(
                    title: "Friends",
                    message: "The friends feature is coming soon. You'll be able to challenge friends and track their progress here."
                )
            case .battles:
                PlaceholderDetailView(
                    title: "Battles",
                    message: "Battles will let you compete head-to-head with other Habit Warriors. Stay tuned!"
                )
            case .habits, .calendar:
                EmptyView()
            }
        }
        .task {
            await loadDashboardData()
        }
    }
    
    /// Load all dashboard data
    private func loadDashboardData() async {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        
        isLoading = true
        
        // Load profile for username
        do {
            if let profile = try await profileService.fetchProfile(userId: userId) {
                username = profile.username
            }
        } catch {
            print("Failed to load profile: \(error)")
        }
        
        // Load stats and streaks in parallel
        async let statsTask = statsService.getQuotaStats(userId: userId, timezone: timezone)
        async let streakTask = statsService.getStreakData(userId: userId)
        
        do {
            stats = try await statsTask
            streakData = try await streakTask
        } catch {
            print("Failed to load stats: \(error)")
        }
        
        isLoading = false
    }
    
    private func handleQuickAction(_ destination: QuickActionDestination) {
        switch destination {
        case .habits:
            selectedTab = 0
        case .calendar:
            selectedTab = 2
        case .friends, .battles:
            quickActionSheet = destination
        }
    }
}

/// Quick action card component
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                LinearGradient(
                    colors: [color.opacity(0.2), color.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

enum QuickActionDestination: Identifiable {
    case habits
    case calendar
    case friends
    case battles
    
    var id: String {
        switch self {
        case .habits: return "habits"
        case .calendar: return "calendar"
        case .friends: return "friends"
        case .battles: return "battles"
        }
    }
}

struct PlaceholderDetailView: View {
    let title: String
    let message: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 56))
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    DashboardView(selectedTab: .constant(1))
        .environmentObject(AuthService())
}

