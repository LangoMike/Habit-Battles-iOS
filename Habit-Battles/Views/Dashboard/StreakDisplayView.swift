//
//  StreakDisplayView.swift
//  Habit-Battles
//
//  Streak display component
//

import SwiftUI

enum StreakVariant {
    case dashboard
    case habits
    case calendar
}

struct StreakDisplayView: View {
    let streakData: StreakData
    let variant: StreakVariant
    var showWeekly: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            if streakData.dailyStreak == 0 && streakData.weeklyStreak == 0 {
                // Empty state
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.gray)
                    Text("Start your streak today!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            } else {
                // Daily Streak
                StreakCard(
                    streak: streakData.dailyStreak,
                    type: .daily,
                    message: getStreakMessage(streakData.dailyStreak, type: .daily),
                    color: .red
                )
                
                // Weekly Streak
                if showWeekly && streakData.weeklyStreak > 0 {
                    StreakCard(
                        streak: streakData.weeklyStreak,
                        type: .weekly,
                        message: getStreakMessage(streakData.weeklyStreak, type: .weekly),
                        color: .orange
                    )
                }
            }
        }
    }
    
    /// Get fire icon based on streak length
    private func getFireIcon(_ streak: Int) -> String {
        if streak < 3 {
            return "bolt.fill"
        } else if streak < 10 {
            return "flame.fill"
        } else {
            return "flame.fill"
        }
    }
    
    /// Get streak message based on variant and streak length
    private func getStreakMessage(_ streak: Int, type: StreakType) -> String {
        let messages: [String]
        
        switch (variant, type) {
        case (.dashboard, .daily):
            messages = [
                "You're on a roll!",
                "Keep the momentum going!",
                "You're unstoppable!",
                "Incredible consistency!",
                "You're a habit warrior!"
            ]
        case (.dashboard, .weekly):
            messages = [
                "Week after week!",
                "Consistent weekly progress!",
                "Weekly warrior!",
                "Building lasting habits!",
                "Week champion!"
            ]
        case (.habits, .daily):
            messages = [
                "Daily habit master!",
                "Consistency is key!",
                "Building daily routines!",
                "Habit formation expert!",
                "Daily discipline!"
            ]
        case (.habits, .weekly):
            messages = [
                "Weekly habit champion!",
                "Weekly routine builder!",
                "Weekly consistency!",
                "Weekly habit master!",
                "Weekly discipline!"
            ]
        case (.calendar, .daily):
            messages = [
                "Calendar warrior!",
                "Filling up that calendar!",
                "Daily tracking master!",
                "Calendar consistency!",
                "Daily progress!"
            ]
        case (.calendar, .weekly):
            messages = [
                "Weekly calendar champion!",
                "Weekly tracking expert!",
                "Weekly calendar master!",
                "Weekly progress!",
                "Weekly tracking!"
            ]
        }
        
        let index = min(streak / 3, messages.count - 1)
        return messages[index]
    }
}

enum StreakType {
    case daily
    case weekly
    
    var unit: String {
        switch self {
        case .daily: return "day"
        case .weekly: return "week"
        }
    }
}

struct StreakCard: View {
    let streak: Int
    let type: StreakType
    let message: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: getFireIcon(streak))
                .foregroundColor(getFireColor(streak))
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(streak) \(type.unit)\(streak != 1 ? "s" : "") in a row")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(color.opacity(0.8))
            }
            
            Spacer()
            
            Text(type == .daily ? "Daily" : "Weekly")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(8)
        }
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
    
    private func getFireIcon(_ streak: Int) -> String {
        if streak < 3 {
            return "bolt.fill"
        } else if streak < 10 {
            return "flame.fill"
        } else {
            return "flame.fill"
        }
    }
    
    private func getFireColor(_ streak: Int) -> Color {
        if streak < 3 {
            return .yellow
        } else if streak < 10 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    StreakDisplayView(
        streakData: StreakData(dailyStreak: 5, weeklyStreak: 3, lastCheckinDate: "2024-01-15"),
        variant: .dashboard
    )
    .padding()
    .background(Color.black)
}
