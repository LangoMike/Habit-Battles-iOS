//
//  Habit_BattlesApp.swift
//  Habit-Battles
//
//  Main app entry point with authentication flow
//

import SwiftUI

@main
struct Habit_BattlesApp: App {
    @StateObject private var authService = AuthService()
    @State private var callbackURL: URL?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isLoading {
                    // Show loading screen while checking session
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                } else if authService.isAuthenticated {
                    // Show main app content when authenticated
                    ContentView()
                        .environmentObject(authService)
                } else if let callbackURL = callbackURL {
                    // Show callback view when handling auth redirect
                    AuthCallbackView(url: callbackURL) {
                        // Clear callback URL after successful authentication
                        self.callbackURL = nil
                    }
                    .environmentObject(authService)
                } else {
                    // Show login screen when not authenticated
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .onOpenURL { url in
                // Handle deep link from magic link email, this brings us to the app from the email
                if url.scheme == "habit-battles" {
                    callbackURL = url
                }
            }
        }
    }
}
