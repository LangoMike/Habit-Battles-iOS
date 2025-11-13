//
//  ContentView.swift
//  Habit-Battles
//
//  Main content view with tab navigation
//

import SwiftUI
internal import Auth

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Habits tab
            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet.clipboard")
                }
                .tag(0)
            
            // Dashboard tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // Calendar tab
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)
            
            // Profile tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.red)
    }
}


/// Profile view with sign out
struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                if let user = authService.currentUser {
                    Text(user.email ?? "User")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        try? await authService.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}

