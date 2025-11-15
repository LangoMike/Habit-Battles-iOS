//
//  ProfileService.swift
//  Habit-Battles
//
//  Service for managing user profiles
//

import Foundation
import Combine
import Supabase

/// Service for handling user profile operations
@MainActor
class ProfileService: ObservableObject {
    @Published var currentProfile: Profile?
    @Published var isLoading = false
    
    private let supabase = SupabaseManager.shared.client
    
    /// Fetch or create user profile
    /// Creates a default profile with generated username if none exists
    func ensureProfile(userId: String) async throws -> Profile {
        isLoading = true
        defer { isLoading = false }
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            let profile = DebugAuthDefaults.profile
            self.currentProfile = profile
            return profile
        }
#endif
        
        // Try to fetch existing profile
        do {
            let response: Supabase.PostgrestResponse<Profile> = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .single()
                .execute()
            
            let profile = response.value
            self.currentProfile = profile
            return profile
        } catch {
            // Profile doesn't exist, will create one below
        }
        
        // Profile doesn't exist, create one with default username
        let defaultUsername = generateDefaultUsername()
        
        let newProfile = Profile(
            id: userId,
            username: defaultUsername,
            avatarUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Insert new profile into database
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let profileJSON = try encoder.encode(newProfile)
        
        try await supabase
            .from("profiles")
            .insert(profileJSON)
            .execute()
        
        self.currentProfile = newProfile
        return newProfile
    }
    
    /// Fetch user profile by ID
    func fetchProfile(userId: String) async throws -> Profile? {
        isLoading = true
        defer { isLoading = false }
        
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            let profile = DebugAuthDefaults.profile
            self.currentProfile = profile
            return profile
        }
#endif
        
        let response: Supabase.PostgrestResponse<Profile> = try await supabase
            .from("profiles")
            .select("*")
            .eq("id", value: userId)
            .single()
            .execute()
        
        let profile = response.value
        self.currentProfile = profile
        return profile
    }
    
    /// Update user profile
    func updateProfile(_ profile: Profile) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let profileJSON = try encoder.encode(profile)
        
        try await supabase
            .from("profiles")
            .update(profileJSON)
            .eq("id", value: profile.id)
            .execute()
        
        self.currentProfile = profile
    }
    
    /// Upload avatar image to Supabase Storage and return public URL
    func uploadAvatarImage(userId: String, imageData: Data, fileExtension: String = "jpg") async throws -> String {
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            return DebugAuthDefaults.profile.avatarUrl ?? ""
        }
#endif
        let path = "avatars/\(userId)/avatar.\(fileExtension)"
        try await supabase.storage
            .from("avatars")
            .upload(
                path: path,
                file: imageData,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
        
        let publicURL = try supabase.storage
            .from("avatars")
            .getPublicURL(path: path)
        
        return publicURL.absoluteString
    }
    
    /// Check if username is available (excludes current user)
    func isUsernameAvailable(_ username: String, excluding userId: String) async throws -> Bool {
#if DEBUG
        if AuthService.isDebugUserId(userId) {
            return true
        }
#endif
        struct UsernameCheckResponse: Decodable {
            let id: String
        }
        
        let response: Supabase.PostgrestResponse<[UsernameCheckResponse]> = try await supabase
            .from("profiles")
            .select("id")
            .eq("username", value: username)
            .neq("id", value: userId)
            .limit(1)
            .execute()
        
        return response.value.isEmpty
    }
    
    /// Generate a default username (User + random 5-digit number)
    private func generateDefaultUsername() -> String {
        let randomNum = Int.random(in: 10000...99999)
        return "User\(randomNum)"
    }
}

