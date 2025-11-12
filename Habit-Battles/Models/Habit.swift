//
//  Habit.swift
//  Habit-Battles
//
//  Habit model matching Supabase habits table
//

import Foundation

/// Habit model matching the Supabase habits table schema
struct Habit: Codable, Identifiable {
    let id: String // UUID
    let userId: String // UUID from auth.users
    var name: String
    var targetPerWeek: Int // 1-7
    var schedule: String // "daily", "weekly", or "custom" (stored as JSONB in DB)
    var timezone: String // Timezone string (e.g., "America/New_York")
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case targetPerWeek = "target_per_week"
        case schedule
        case timezone
        case createdAt = "created_at"
    }
}

/// Extended habit model with progress tracking
struct HabitWithProgress: Identifiable {
    let habit: Habit
    var doneToday: Bool
    var doneThisWeek: Int
    
    var id: String { habit.id }
    var name: String { habit.name }
    var targetPerWeek: Int { habit.targetPerWeek }
}

