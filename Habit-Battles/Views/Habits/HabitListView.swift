//
//  HabitListView.swift
//  Habit-Battles
//
//  Main habit list view with check-in functionality
//

import SwiftUI
internal import Auth

struct HabitListView: View {
    @StateObject private var habitService = HabitService()
    @EnvironmentObject var authService: AuthService
    @State private var showingCreateDialog = false
    @State private var showingEditDialog = false
    @State private var selectedHabit: Habit?
    @State private var errorMessage: String?
    
    // Get user's timezone
    private var timezone: String {
        TimeZone.current.identifier
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Your Habits")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingCreateDialog = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    
                    // Habits list
                    if habitService.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                    } else if habitService.habits.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                            
                            Text("No habits yet")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Create your first habit to start tracking!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { showingCreateDialog = true }) {
                                Text("Create Habit")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 200)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(habitService.habits) { habitWithProgress in
                                    HabitRowView(
                                        habitWithProgress: habitWithProgress,
                                        onCheckIn: { checkInHabit(habitWithProgress.habit.id) },
                                        onEdit: { 
                                            selectedHabit = habitWithProgress.habit
                                            showingEditDialog = true
                                        },
                                        onDelete: { deleteHabit(habitWithProgress.habit.id) }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateDialog) {
                CreateHabitView(
                    userId: authService.currentUser?.id.uuidString ?? "",
                    timezone: timezone,
                    onDismiss: {
                        showingCreateDialog = false
                        Task {
                            await refreshHabits()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingEditDialog) {
                if let habit = selectedHabit {
                    EditHabitView(
                        habit: habit,
                        userId: authService.currentUser?.id.uuidString ?? "",
                        timezone: timezone,
                        onDismiss: {
                            showingEditDialog = false
                            selectedHabit = nil
                            Task {
                                await refreshHabits()
                            }
                        }
                    )
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await refreshHabits()
        }
    }
    
    /// Refresh habits list
    private func refreshHabits() async {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        
        do {
            try await habitService.fetchHabits(userId: userId, timezone: timezone)
        } catch {
            errorMessage = "Failed to load habits: \(error.localizedDescription)"
        }
    }
    
    /// Handle check-in for a habit
    private func checkInHabit(_ habitId: String) {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        
        Task {
            do {
                try await habitService.checkIn(habitId: habitId, userId: userId, timezone: timezone)
            } catch {
                let errorMsg = error.localizedDescription
                if errorMsg.contains("Already checked in") {
                    errorMessage = "Already checked in for today!"
                } else {
                    errorMessage = "Failed to check in: \(errorMsg)"
                }
            }
        }
    }
    
    /// Delete a habit
    private func deleteHabit(_ habitId: String) {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        
        Task {
            do {
                try await habitService.deleteHabit(habitId: habitId, userId: userId, timezone: timezone)
            } catch {
                errorMessage = "Failed to delete habit: \(error.localizedDescription)"
            }
        }
    }
}

/// Individual habit row view
struct HabitRowView: View {
    let habitWithProgress: HabitWithProgress
    let onCheckIn: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(habitWithProgress.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(habitWithProgress.doneThisWeek) / \(habitWithProgress.targetPerWeek) this week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if habitWithProgress.doneToday {
                // Already checked in today
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Done")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            } else {
                // Check in button
                Button(action: onCheckIn) {
                    Text("Check In")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    HabitListView()
        .environmentObject(AuthService())
}

