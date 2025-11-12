# Xcode Setup Instructions

This document contains **exact step-by-step instructions** for setting up the Habit Battles iOS app in Xcode.

## Prerequisites

- Xcode installed (latest version recommended)
- macOS with Apple Developer account (for running on device)
- Internet connection (for adding Swift packages)

---

## Step 1: Add Supabase Swift Package

1. **Open the project**
   - Open `Habit-Battles.xcodeproj` in Xcode
   - Wait for Xcode to finish indexing

2. **Add Package Dependency**
   - In Xcode menu: **File > Add Package Dependencies...**
   - In the search field, paste: `https://github.com/supabase/supabase-swift`
   - Click **Add Package**
   - Select version **2.x** or latest stable version
   - Make sure **Habit-Battles** target is checked
   - Click **Add Package**

3. **Verify Package Added**
   - In Project Navigator, you should see **Package Dependencies** section
   - Expand it to see `supabase-swift`

---

## Step 2: Configure URL Scheme for Magic Links

1. **Select Project Target**
   - In Project Navigator, click on **Habit-Battles** project (blue icon at top)
   - Select **Habit-Battles** target under **TARGETS**

2. **Open Info Tab**
   - Click on **Info** tab at the top

3. **Add URL Type**
   - Scroll down to **URL Types** section
   - Click the **+** button to add a new URL Type
   - Expand the new URL Type entry
   - Set **Identifier**: `com.habitbattles.auth`
   - Set **URL Schemes**: `habit-battles`
   - Leave **Role** as default (Editor)
   - Leave **Icon** empty

4. **Verify Configuration**
   - Your URL Type should look like:
     ```
     Identifier: com.habitbattles.auth
     URL Schemes: habit-battles
     ```

---

## Step 3: Build and Test

1. **Select Simulator/Device**
   - In Xcode toolbar, select a simulator (e.g., "iPhone 15 Pro")
   - Or connect your iPhone and select it

2. **Build Project**
   - Press **⌘B** (Command + B) or **Product > Build**
   - Wait for build to complete
   - Fix any compilation errors (see Troubleshooting below)

3. **Run App**
   - Press **⌘R** (Command + R) or click **Play** button
   - App should launch on simulator/device

---

## Step 4: Test Authentication

1. **Launch App**
   - App should show login screen

2. **Test Magic Link**
   - Enter your email address
   - Click "Sign In"
   - Check your email for magic link
   - Click the link in email
   - App should authenticate and show main content

**Note**: Magic links work best on a physical device. On simulator, you may need to manually handle the callback URL.

---

## Troubleshooting

### Build Errors

#### "Cannot find 'Supabase' in scope"
- **Solution**: Make sure Supabase package was added to the correct target
- Go to **File > Packages > Reset Package Caches**
- Then **File > Packages > Update to Latest Package Versions**

#### API Method Errors
- The Supabase Swift SDK API may differ slightly from what's in the code
- Check `SUPABASE_API_NOTES.md` for common adjustments
- Refer to [Supabase Swift SDK Documentation](https://github.com/supabase/supabase-swift)

#### "No such module 'Supabase'"
- **Solution**: 
  1. Clean build folder: **Product > Clean Build Folder** (⇧⌘K)
  2. Close Xcode
  3. Delete `DerivedData` folder: `~/Library/Developer/Xcode/DerivedData`
  4. Reopen Xcode and rebuild

### Magic Link Not Working

#### Links Don't Open App
- **Solution**: Verify URL scheme is configured correctly (Step 2)
- Check that URL scheme matches: `habit-battles://auth/callback`
- Try manually opening: `habit-battles://auth/callback` in Safari

#### Authentication Fails
- **Solution**: 
  1. Check Supabase credentials in `SupabaseConfig.swift`
  2. Verify your Supabase project is active
  3. Check Supabase project logs for errors

### Runtime Errors

#### "Failed to load habits"
- **Solution**: 
  1. Verify you're authenticated
  2. Check Supabase connection
  3. Verify database tables exist (profiles, habits, checkins)

#### App Crashes on Launch
- **Solution**:
  1. Check Xcode console for error messages
  2. Verify all required files are included in target
  3. Check that models match database schema

---

## Next Steps After Setup

Once the app builds and runs successfully:

1. ✅ Test authentication flow
2. ✅ Create a test habit
3. ✅ Complete a check-in
4. ✅ View dashboard stats
5. ✅ Check calendar view
6. ✅ Test on physical device (recommended for magic links)

---

## Additional Notes

- **Supabase Credentials**: Already configured via MCP (see `SupabaseClient.swift`)
- **API Compatibility**: May need minor adjustments based on SDK version (see `SUPABASE_API_NOTES.md`)
- **Apple Watch**: Watch app will be added later (see `APPLE_WATCH.md`)

---

## Getting Help

If you encounter issues:

1. Check Xcode console for detailed error messages
2. Review `SUPABASE_API_NOTES.md` for API compatibility notes
3. Verify all steps were completed correctly
4. Check Supabase project dashboard for backend errors

---

**Last Updated**: After initial project setup
**Xcode Version**: Latest recommended
**Supabase SDK**: Version 2.x

