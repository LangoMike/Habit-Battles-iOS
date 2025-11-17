//
//  AuthCallbackView.swift
//  Habit-Battles
//
//  Handles OAuth callback from magic link email
//

import SwiftUI
import Supabase

struct AuthCallbackView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let url: URL
    let onComplete: () -> Void
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Completing sign in...")
                    .foregroundColor(.white)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text("Sign In Failed")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            handleCallback()
        }
    }
    
    /// Handle the OAuth callback URL
    private func handleCallback() {
        Task {
            do {
                // Extract token from URL and complete authentication
                let supabase = SupabaseManager.shared.client
                try await supabase.auth.session(from: url)
                
                // Refresh session in the shared auth service
                await authService.checkSession()
                
                // Wait a moment for state to propagate
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                // Notify parent that authentication is complete
                await MainActor.run {
                    isLoading = false
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}



