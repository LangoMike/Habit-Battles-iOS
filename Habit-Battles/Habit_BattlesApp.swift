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
                } else {
                    // Show login screen when not authenticated
                    LoginView()
                }
            }
            .environmentObject(authService)
        }
    }
}
