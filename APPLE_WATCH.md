# Apple Watch App Architecture

## Overview

The Habit Battles iOS app includes an Apple Watch companion app with **simplified functionality focused on check-ins only**. This document outlines the architecture and implementation plan.

## Requirements

- **Primary Platform**: iPhone (full functionality)
- **Secondary Platform**: Apple Watch (check-ins only)
- **Shared Backend**: Same Supabase database for both platforms

## Apple Watch Features

### ✅ Core Functionality
- **View habits list** (read-only, simplified UI)
- **Complete check-ins** (one-tap check-in for habits)
- **Sync with iPhone** (real-time via Supabase)

### ❌ Not Included (iPhone only)
- Create/edit/delete habits
- Dashboard and stats
- Calendar view
- Friends system
- Profile management

## Architecture

### Data Flow

```
┌─────────────────┐         ┌─────────────────┐
│   Apple Watch   │◄───────►│   Supabase      │
│                 │         │   Backend       │
│  Check-ins Only │         │                 │
└─────────────────┘         └─────────────────┘
                                      ▲
                                      │
                             ┌────────┴────────┐
                             │                │
                      ┌──────┴──────┐  ┌──────┴──────┐
                      │   iPhone    │  │   Web App   │
                      │  Full App   │  │             │
                      └─────────────┘  └─────────────┘
```

### Implementation Plan

1. **WatchKit App Target**
   - Create new WatchKit app target in Xcode
   - Configure Watch Connectivity for iPhone communication (optional - can use Supabase directly)
   - Set up Supabase client for Watch app

2. **Watch App Views**
   - `HabitListView.swift` (Watch) - Simple list of habits
   - `CheckInView.swift` (Watch) - One-tap check-in interface
   - Minimal UI optimized for small screen

3. **Watch Services**
   - `WatchHabitService.swift` - Simplified service for fetching habits and check-ins only
   - Reuse `HabitService` from iPhone app where possible
   - Optimize for Watch performance (minimal data fetching)

4. **Authentication**
   - Share authentication state between iPhone and Watch
   - Use Watch Connectivity or Keychain sharing
   - Or: Watch app can authenticate independently via Supabase

## Implementation Notes

- Watch app will use the same Supabase backend
- Check-ins sync in real-time with iPhone and web app
- UI optimized for Watch's small screen and quick interactions
- Focus on speed: minimal taps to complete a check-in

## Future Enhancements

- Push notifications for reminders
- Complications for quick habit status
- Haptic feedback on check-in completion



