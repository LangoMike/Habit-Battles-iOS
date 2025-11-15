//
//  ContentView.swift
//  Habit-Battles
//
//  Main content view with tab navigation
//

import SwiftUI
import PhotosUI
import UIKit
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
            DashboardView(selectedTab: $selectedTab)
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


/// Profile view with editable details
struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var profileService = ProfileService()
    
    @State private var usernameInput = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarPreview: Image?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    avatarView
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Change Profile Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(20)
                    }
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Info")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("Enter username", text: $usernameInput)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(authService.currentUser?.email ?? "No email")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let successMessage {
                    Text(successMessage)
                        .font(.caption)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: saveProfile) {
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
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isSaving)
                
                Button(role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                } label: {
                    Text("Sign Out")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onChange(of: selectedPhotoItem) { newItem in
            guard let item = newItem else { return }
            Task {
                await uploadAvatar(from: item)
            }
        }
        .task {
            await loadProfile()
        }
    }
    
    private var avatarView: some View {
        Group {
            if let avatarPreview {
                avatarPreview
                    .resizable()
                    .scaledToFill()
            } else if let urlString = profileService.currentProfile?.avatarUrl,
                      let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholderAvatar
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else {
                placeholderAvatar
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.red.opacity(0.8), lineWidth: 3)
        )
    }
    
    private var placeholderAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
    }
    
    private func loadProfile() async {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        do {
            let profile = try await profileService.ensureProfile(userId: userId)
            await MainActor.run {
                usernameInput = profile.username
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load profile: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveProfile() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            defer { isSaving = false }
            guard var profile = profileService.currentProfile,
                  let userId = authService.currentUser?.id.uuidString else {
                errorMessage = "No profile available."
                return
            }
            
            let trimmed = usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                errorMessage = "Username cannot be empty."
                return
            }
            
            do {
                if trimmed != profile.username {
                    let available = try await profileService.isUsernameAvailable(trimmed, excluding: userId)
                    guard available else {
                        errorMessage = "Username already taken."
                        return
                    }
                    profile.username = trimmed
                }
                
                try await profileService.updateProfile(profile)
                await MainActor.run {
                    profileService.currentProfile = profile
                    successMessage = "Profile updated successfully."
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save changes: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func uploadAvatar(from item: PhotosPickerItem) async {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                await MainActor.run {
                    errorMessage = "Could not read selected image."
                }
                return
            }
            
            let url = try await profileService.uploadAvatarImage(userId: userId, imageData: data)
            if var profile = profileService.currentProfile {
                profile.avatarUrl = url
                try await profileService.updateProfile(profile)
                await MainActor.run {
                    profileService.currentProfile = profile
                    if let uiImage = UIImage(data: data) {
                        avatarPreview = Image(uiImage: uiImage)
                    } else {
                        avatarPreview = nil
                    }
                    successMessage = "Profile photo updated."
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to update photo: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}

