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
#if DEBUG
    @Published var isDebugAuthenticated = false
#endif
    
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
#if DEBUG
            self.isDebugAuthenticated = false
#endif
            
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
#if DEBUG
            self.isDebugAuthenticated = false
#endif
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
    
    /// Sign in with Google OAuth provider
    /// Opens browser for OAuth authentication, redirects back to app via deep link
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Initiate OAuth flow with Google provider
        // Opens browser/Safari View Controller for user to authenticate
        try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "habit-battles://auth/callback")
        )
    }
    
    /// Sign in with GitHub OAuth provider
    /// Opens browser for OAuth authentication, redirects back to app via deep link
    func signInWithGitHub() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Initiate OAuth flow with GitHub provider
        // Opens browser/Safari View Controller for user to authenticate
        try await supabase.auth.signInWithOAuth(
            provider: .github,
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
#if DEBUG
        self.isDebugAuthenticated = false
#endif
    }
    
    /// Get the current authenticated user
    func getCurrentUser() async -> User? {
#if DEBUG
        if isDebugAuthenticated {
            return currentUser
        }
#endif
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
    func debugAuthenticate(userId: String = DebugAuthDefaults.userId, email: String = DebugAuthDefaults.email) {
        let resolvedUserId = userId.isEmpty ? DebugAuthDefaults.userId : userId
        let resolvedEmail = email.isEmpty ? DebugAuthDefaults.email : email
        
        // Build a minimal JSON payload that matches Supabase User shape
        let isoFormatter = ISO8601DateFormatter()
        let timestamp = isoFormatter.string(from: Date())
        let payload: [String: Any] = [
            "id": resolvedUserId,
            "app_metadata": [:],
            "user_metadata": [:],
            "aud": "authenticated",
            "confirmation_sent_at": NSNull(),
            "recovery_sent_at": NSNull(),
            "email_change_sent_at": NSNull(),
            "new_email": NSNull(),
            "invited_at": NSNull(),
            "email": resolvedEmail,
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
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let fakeUser = try decoder.decode(User.self, from: data)
            
            // Update published auth state for simulator testing
            self.currentUser = fakeUser
            self.isAuthenticated = true
            self.isLoading = false
            self.isDebugAuthenticated = true
            self.profileService.currentProfile = DebugAuthDefaults.profile
        } catch {
            print("Failed to build debug session: \(error)")
        }
    }
#endif
}

#if DEBUG
extension AuthService {
    /// Helper to detect when a supplied user id represents the debug bypass account
    static func isDebugUserId(_ id: String) -> Bool {
        id == DebugAuthDefaults.userId
    }
}

/// Canonical values and sample data used by the simulator debug bypass
enum DebugAuthDefaults {
    static let userId = "00000000-0000-4000-8000-000000000001"
    static let email = "simulator@habitbattles.dev"
    static let username = "Demo Warrior"
    static let timezone = "America/New_York"
    
    static var profile: Profile {
        Profile(
            id: userId,
            username: username,
            avatarUrl: "https://placehold.co/200x200?text=HB",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func sampleHabits() -> [HabitWithProgress] {
        let now = Date()
        let habitOne = Habit(
            id: UUID().uuidString,
            userId: userId,
            name: "Morning Run",
            targetPerWeek: 4,
            schedule: "daily",
            timezone: timezone,
            createdAt: now
        )
        
        let habitTwo = Habit(
            id: UUID().uuidString,
            userId: userId,
            name: "Reading Session",
            targetPerWeek: 5,
            schedule: "daily",
            timezone: timezone,
            createdAt: now
        )
        
        let habitThree = Habit(
            id: UUID().uuidString,
            userId: userId,
            name: "Hydration Check",
            targetPerWeek: 7,
            schedule: "daily",
            timezone: timezone,
            createdAt: now
        )
        
        return [
            HabitWithProgress(habit: habitOne, doneToday: true, doneThisWeek: 3),
            HabitWithProgress(habit: habitTwo, doneToday: false, doneThisWeek: 2),
            HabitWithProgress(habit: habitThree, doneToday: true, doneThisWeek: 6)
        ]
    }
    
    static func sampleQuotaStats() -> QuotaStats {
        let progress = sampleHabits().map { habitWithProgress in
            HabitProgress(
                habitId: habitWithProgress.id,
                habitName: habitWithProgress.name,
                target: habitWithProgress.targetPerWeek,
                completed: habitWithProgress.doneThisWeek,
                isMet: habitWithProgress.doneThisWeek >= habitWithProgress.targetPerWeek
            )
        }
        
        let weeklyMet = progress.filter { $0.isMet }.count
        let totalCheckins = progress.reduce(0) { $0 + $1.completed }
        
        return QuotaStats(
            weeklyQuotasMet: weeklyMet,
            totalCheckins: totalCheckins,
            totalHabits: progress.count,
            currentWeekProgress: progress
        )
    }
    
    static func sampleStreakData() -> StreakData {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        return StreakData(
            dailyStreak: 4,
            weeklyStreak: 3,
            lastCheckinDate: today
        )
    }
    
    static func sampleCalendarCheckins() -> [CalendarCheckIn] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()
        let habits = sampleHabits()
        
        return (0..<12).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let habit = habits[offset % habits.count]
            return CalendarCheckIn(
                id: UUID().uuidString,
                habitName: habit.name,
                checkinDate: formatter.string(from: date),
                createdAt: date
            )
        }
    }
}
#endif

