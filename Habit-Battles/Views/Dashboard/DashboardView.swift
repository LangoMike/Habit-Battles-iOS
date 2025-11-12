//
//  DashboardView.swift
//  Habit-Battles
//
//  Main dashboard with stats, streaks, and motivational content
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var statsService = StatsService()
    @StateObject private var profileService = ProfileService()
    
    @State private var stats: QuotaStats?
    @State private var streakData: StreakData?
    @State private var username: String?
    @State private var isLoading = true
    
    private var timezone: String {
        TimeZone.current.identifier
    }
    
    var body: some View {
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
                            color: .red
                        )
                        
                        QuickActionCard(
                            icon: "calendar",
                            title: "View Calendar",
                            subtitle: "See your progress",
                            color: .red
                        )
                        
                        QuickActionCard(
                            icon: "person.2.fill",
                            title: "Friends",
                            subtitle: "Connect & compete",
                            color: .red
                        )
                        
                        QuickActionCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Battles",
                            subtitle: "Join competitions",
                            color: .red
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
        )
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
}

/// Quick action card component
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
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
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}

