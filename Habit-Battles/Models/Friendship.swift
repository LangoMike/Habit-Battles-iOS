//
//  Friendship.swift
//  Habit-Battles
//
//  Friendship model matching Supabase friendships table
//

import Foundation

/// Friendship model matching the Supabase friendships table schema
/// Note: This table uses a composite primary key (user_id, friend_id) instead of a single id field
struct Friendship: Codable, Identifiable {
    // Composite key: user_id + friend_id (no separate id field)
    let userId: String // UUID from auth.users
    let friendId: String // UUID reference to profiles
    var status: FriendshipStatus
    let createdAt: Date?
    
    // Computed id for Identifiable conformance (combines both keys)
    var id: String {
        "\(userId)_\(friendId)"
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case friendId = "friend_id"
        case status
        case createdAt = "created_at"
    }
}

/// Friendship status enum
enum FriendshipStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case blocked = "blocked"
}

