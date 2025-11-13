//
//  AuthService.swift
//  Habit-Battles
//
//  Authentication service using Supabase Auth
//

import Foundation
import Combine
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
        defer { isLoading = false }
        
        do {
            // Fetch current session (throws if none available)
            let session = try await supabase.auth.session
            let user = session.user
            self.currentUser = user
            self.isAuthenticated = true
            
            // Ensure user has a profile (create default if needed)
            do {
                _ = try await profileService.ensureProfile(userId: user.id.uuidString)
            } catch {
                print("Warning: Failed to ensure profile: \(error)")
                // Continue anyway - profile creation can be retried later
            }
        } catch {
            // No active session
            self.currentUser = nil
            self.isAuthenticated = false
        }
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
            let session = try await supabase.auth.session
            return session.user
        } catch {
            return nil
        }
    }
    
#if DEBUG
    /// Create a debug session so simulators can skip email login
    /// - Parameters:
    ///   - userId: Known Supabase auth user UUID to mimic (optional)
    ///   - email: Debug email shown in profile (optional)
    func debugAuthenticate(userId: String = DebugBypassDefaults.userId, email: String = DebugBypassDefaults.email) {
        // Bail out if no debug user provided
        guard !userId.isEmpty else {
            print("Debug bypass requires a userId")
            return
        }
        
        // Build a minimal JSON payload that matches Supabase User shape
        let isoFormatter = ISO8601DateFormatter()
        let timestamp = isoFormatter.string(from: Date())
        let payload: [String: Any] = [
            "id": userId,
            "app_metadata": [:],
            "user_metadata": [:],
            "aud": "authenticated",
            "confirmation_sent_at": NSNull(),
            "recovery_sent_at": NSNull(),
            "email_change_sent_at": NSNull(),
            "new_email": NSNull(),
            "invited_at": NSNull(),
            "email": email,
            "phone": NSNull(),
            "last_sign_in_at": timestamp,
            "role": "authenticated",
            "created_at": timestamp,
            "updated_at": timestamp,
            "identities": []
        ]
        
        do {
            // Serialize payload into Supabase User model
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let fakeUser = try decoder.decode(User.self, from: data)
            
            // Update published auth state for simulator testing
            self.currentUser = fakeUser
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            print("Failed to build debug session: \(error)")
        }
    }
    
    /// Default values for the debug bypass helper
    private enum DebugBypassDefaults {
        /// Replace with a real Supabase auth user id to test backend calls
        static let userId = ""
        /// Fake login email shown in the profile tab
        static let email = "debugger@habitbattles.dev"
    }
#endif
}

