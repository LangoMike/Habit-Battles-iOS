//
//  CheckIn.swift
//  Habit-Battles
//
//  Check-in model matching Supabase checkins table
//

import Foundation

/// Check-in model matching the Supabase checkins table schema
struct CheckIn: Codable, Identifiable {
    let id: String // UUID
    let userId: String // UUID from auth.users
    let habitId: String // UUID reference to habits
    let checkinDate: String // ISO date string (YYYY-MM-DD)
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case habitId = "habit_id"
        case checkinDate = "checkin_date"
        case createdAt = "created_at"
    }
}



