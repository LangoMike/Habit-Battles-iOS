//
//  CreateHabitView.swift
//  Habit-Battles
//
//  View for creating a new habit
//

import SwiftUI

struct CreateHabitView: View {
    let userId: String
    let timezone: String
    let onDismiss: () -> Void
    
    @StateObject private var habitService = HabitService()
    @State private var name = ""
    @State private var targetPerWeek = 3
    @State private var errorMessage: String?
    @State private var isCreating = false
    
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
                        
                        TextField("e.g., Code 30 minutes", text: $name)
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
                        
                        Stepper(value: $targetPerWeek, in: 1...7) {
                            Text("\(targetPerWeek) times per week")
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
                    
                    Button(action: createHabit) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Habit")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isCreating || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Habit")
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
    
    /// Create the habit
    private func createHabit() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await habitService.createHabit(
                    userId: userId,
                    name: name,
                    targetPerWeek: targetPerWeek,
                    timezone: timezone
                )
                onDismiss()
            } catch {
                errorMessage = "Failed to create habit: \(error.localizedDescription)"
                isCreating = false
            }
        }
    }
}

#Preview {
    CreateHabitView(
        userId: "test-user-id",
        timezone: "America/New_York",
        onDismiss: {}
    )
}



