//
//  StatsCardsView.swift
//  Habit-Battles
//
//  Statistics cards component
//

import SwiftUI

struct StatsCardsView: View {
    let stats: QuotaStats
    
    private var quotaPercentage: Int {
        stats.totalHabits > 0
            ? Int((Double(stats.weeklyQuotasMet) / Double(stats.totalHabits)) * 100)
            : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Weekly Quotas Met
            StatCard(
                icon: "trophy.fill",
                title: "Weekly Quotas Met",
                value: "\(stats.weeklyQuotasMet)/\(stats.totalHabits)",
                subtitle: "\(quotaPercentage)% Success Rate",
                badge: "This Week",
                color: .red
            )
            
            // Total Check-ins
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Total Check-ins",
                value: "\(stats.totalCheckins)",
                subtitle: "\(stats.totalHabits) Active Habits",
                badge: "All Time",
                color: .red
            )
            
            // Weekly Progress
            StatCard(
                icon: "target",
                title: "Weekly Progress",
                value: nil,
                subtitle: nil,
                badge: "Progress",
                color: .red,
                progressItems: stats.currentWeekProgress
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String?
    let subtitle: String?
    let badge: String
    let color: Color
    var progressItems: [HabitProgress]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(badge)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .cornerRadius(8)
            }
            
            if let value = value {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if let progressItems = progressItems, !progressItems.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(progressItems, id: \.habitId) { item in
                            HStack {
                                Text(item.habitName)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(item.completed)/\(item.target)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(item.isMet ? .green : color)
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
            } else if progressItems != nil {
                Text("No habits yet")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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
    StatsCardsView(
        stats: QuotaStats(
            weeklyQuotasMet: 3,
            totalCheckins: 45,
            totalHabits: 5,
            currentWeekProgress: [
                HabitProgress(habitId: "1", habitName: "Exercise", target: 3, completed: 3, isMet: true),
                HabitProgress(habitId: "2", habitName: "Read", target: 5, completed: 2, isMet: false)
            ]
        )
    )
    .padding()
    .background(Color.black)
}

