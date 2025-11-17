//
//  EditHabitView.swift
//  Habit-Battles
//
//  View for editing an existing habit
//

import SwiftUI

struct EditHabitView: View {
    @State var habit: Habit
    let userId: String
    let timezone: String
    let onDismiss: () -> Void
    
    @StateObject private var habitService = HabitService()
    @State private var errorMessage: String?
    @State private var isSaving = false
    
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
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Habit name", text: $habit.name)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocapitalization(.words)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target per week (1-7)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Stepper(value: $habit.targetPerWeek, in: 1...7) {
                            Text("\(habit.targetPerWeek) times per week")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Button(action: saveHabit) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSaving || habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    /// Save the habit changes
    private func saveHabit() {
        guard !habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                try await habitService.updateHabit(habit, userId: userId, timezone: timezone)
                onDismiss()
            } catch {
                errorMessage = "Failed to update habit: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }
}

#Preview {
    EditHabitView(
        habit: Habit(
            id: "test-id",
            userId: "test-user",
            name: "Test Habit",
            targetPerWeek: 3,
            schedule: "daily",
            timezone: "America/New_York",
            createdAt: Date()
        ),
        userId: "test-user-id",
        timezone: "America/New_York",
        onDismiss: {}
    )
}



