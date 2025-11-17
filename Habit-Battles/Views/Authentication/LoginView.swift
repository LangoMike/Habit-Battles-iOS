//
//  LoginView.swift
//  Habit-Battles
//
//  Login screen with email magic link authentication
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo and title
            VStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                
                Text("Habit Battles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Fight the old you. Build the new you.")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Login form
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if showSuccessMessage {
                    Text("Check your email for the magic link!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                Button(action: handleSignIn) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading || email.isEmpty)
                .opacity((isLoading || email.isEmpty) ? 0.6 : 1.0)
#if DEBUG
#if targetEnvironment(simulator)
                Button {
                    // Skip email login while running on the simulator
                    authService.debugAuthenticate()
                } label: {
                    Text("Debug Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
#endif
#endif
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Handle sign in with email magic link
    private func handleSignIn() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        showSuccessMessage = false
        
        Task {
            do {
                try await authService.signInWithEmail(email)
                showSuccessMessage = true
            } catch {
                errorMessage = "Failed to send magic link: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}


