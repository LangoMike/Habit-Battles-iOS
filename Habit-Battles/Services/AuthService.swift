//
//  AuthService.swift
//  Habit-Battles
//
//  Authentication service using Supabase Auth
//

import Foundation
import Supabase

/// Service for handling authentication operations
@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let supabase = SupabaseManager.shared.client
    private let profileService = ProfileService()
    
    init() {
        // Check for existing session on init
        Task {
            await checkSession()
        }
    }
    
    /// Check if user has an active session and ensure profile exists
    func checkSession() async {
        isLoading = true
        do {
            // Get current session from Supabase
            let session = try await supabase.auth.session
            if let user = session.user {
                self.currentUser = user
                self.isAuthenticated = true
                
                // Ensure user has a profile (create default if needed)
                do {
                    _ = try await profileService.ensureProfile(userId: user.id.uuidString)
                } catch {
                    print("Warning: Failed to ensure profile: \(error)")
                    // Continue anyway - profile creation can be retried later
                }
            } else {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            // No active session
            self.currentUser = nil
            self.isAuthenticated = false
        }
        isLoading = false
    }
    
    /// Sign in with email magic link (passwordless authentication)
    /// - Parameter email: User's email address
    func signInWithEmail(_ email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Send magic link email via Supabase Auth
        // The redirectTo URL should match your app's URL scheme
        try await supabase.auth.signInWithOTP(
            email: email,
            redirectTo: URL(string: "habit-battles://auth/callback")
        )
    }
    
    /// Sign out the current user
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Sign out from Supabase
        try await supabase.auth.signOut()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    /// Get the current authenticated user
    func getCurrentUser() async -> User? {
        do {
            let user = try await supabase.auth.user
            return user
        } catch {
            return nil
        }
    }
}

