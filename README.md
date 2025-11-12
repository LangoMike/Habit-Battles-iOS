# Habit Battles iOS App

**"Fight the old you. Build the new you."**

iOS version of the Habit Battles webapp, connecting to the same Supabase backend for shared data and real-time synchronization.

## Setup Instructions

### Supabase Credentials - Done

Your Supabase credentials have been automatically configured via MCP connection. The app is ready to connect to your backend!

### 1. Add Supabase Swift Package (Required)

**You need to add the Supabase Swift package in Xcode:**

1. Open `Habit-Battles.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies...** (or **File > Add Packages...**)
3. Enter the package URL: `https://github.com/supabase/supabase-swift`
4. Select version **2.x** or latest stable version
5. Make sure to add it to your **Habit-Battles** target
6. Click **Add Package**

**Alternative:** If you prefer using Swift Package Manager via command line, you can add it to your `Package.swift` file, but Xcode UI is recommended.

### 2. Configure URL Scheme for Magic Links (Required)

**Set up the URL scheme so magic links work:**

1. In Xcode, select your project in the navigator
2. Select the **Habit-Battles** target
3. Go to the **Info** tab
4. Expand **URL Types** (if not visible, click the **+** button)
5. Add a new URL Type with:
   - **Identifier**: `com.habitbattles.auth`
   - **URL Schemes**: `habit-battles`
   - **Role**: Editor (or leave default)
6. This allows the app to handle magic link callbacks from email

### 3. Build and Run

Once you've added the Supabase package and configured the URL scheme:
1. Build the project (⌘B)
2. Run the app (⌘R)
3. The app should connect to your Supabase backend and share data with your webapp!

### Troubleshooting

- **Package not found**: Make sure you're connected to the internet and the package URL is correct
- **Build errors**: Check that the Supabase package was added to the correct target
- **Magic links not working**: Verify the URL scheme is configured correctly in Info tab

## Project Structure

```
Habit-Battles/
├── Models/              # Data models matching Supabase schema
│   ├── Profile.swift
│   ├── Habit.swift
│   ├── CheckIn.swift
│   └── Friendship.swift
├── Services/            # Business logic and API services
│   ├── SupabaseClient.swift
│   └── AuthService.swift
└── Views/               # SwiftUI views
    ├── Authentication/
    │   ├── LoginView.swift
    │   └── AuthCallbackView.swift
    └── ContentView.swift
```

## Features (In Progress)

### iPhone App
- ✅ Supabase integration
- ✅ Authentication with email magic links
- ✅ Profile creation and management
- ✅ Core habit tracking (CRUD + check-ins)
- ✅ Habit list with progress tracking
- ✅ Dashboard with stats cards, streaks, and motivational quotes
- ✅ Calendar view with week/month/year modes and heatmap visualization
- 🚧 Friends system

### Apple Watch App (Planned)
- 🚧 View habits list (read-only)
- 🚧 Complete check-ins (one-tap)
- 🚧 Real-time sync with iPhone/web app

**Note**: Apple Watch app will have simplified functionality focused on check-ins only. See `APPLE_WATCH.md` for architecture details.

## Notes

- This app uses the **same Supabase database** as the webapp
- Users can log in with the same account on both platforms
- Real-time updates sync across web and iOS
- Data is shared between platforms

