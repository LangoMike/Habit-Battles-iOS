//
//  Profile.swift
//  Habit-Battles
//
//  User profile model matching Supabase profiles table
//

import Foundation

/// User profile model matching the Supabase profiles table schema
struct Profile: Codable, Identifiable {
    let id: String // UUID from auth.users
    var username: String
    var avatarUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}



