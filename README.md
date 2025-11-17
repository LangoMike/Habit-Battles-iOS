# Habit Battles iOS

**"Fight the old you. Build the new you."**

A production-ready iOS application for habit tracking and social competition, built with SwiftUI and integrated with Supabase for real-time data synchronization. This app extends the Habit Battles web application to iOS, providing users with a native mobile experience while sharing data seamlessly across platforms.

---

## Project Overview

Habit Battles iOS demonstrates modern iOS development practices with a focus on:
- **Native iOS Experience**: SwiftUI-based interface following Apple Human Interface Guidelines
- **Real-time Synchronization**: Supabase backend integration for instant data updates
- **Cross-platform Compatibility**: Shared database with web application for unified user experience
- **Modern Architecture**: Clean separation of concerns with Models, Services, and Views
- **Performance**: Optimized for fast, responsive user interactions

---

## Features

### Core Functionality

**Authentication & User Management**
- Passwordless email authentication via magic links
- Automatic profile creation with default username generation
- Secure session management with Supabase Auth

**Habit Tracking**
- Create, edit, and delete habits with custom weekly targets (1-7x per week)
- One-tap daily check-ins with duplicate prevention
- Real-time progress tracking (completed vs. target for current week)
- Visual indicators for today's completion status

**Dashboard & Analytics**
- Comprehensive statistics dashboard with key metrics
- Weekly quota tracking and success rate calculations
- Daily and weekly streak visualization
- Motivational quotes integration
- Quick action cards for navigation

**Calendar Visualization**
- Interactive calendar with week, month, and year view modes
- Heatmap visualization showing habit completion intensity
- Date-specific check-in details on tap
- Visual progress tracking over time

**User Interface**
- Dark theme design matching web application aesthetic
- Red and white accent colors for visual consistency
- Tab-based navigation for intuitive access
- Responsive layouts optimized for iPhone

---

## Technical Architecture

### Technology Stack

- **Framework**: SwiftUI (iOS 17+)
- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **Language**: Swift
- **Architecture**: MVVM pattern with ObservableObject services
- **Data Models**: Codable structs matching Supabase schema


### Key Design Patterns

- **Service Layer**: Centralized business logic in ObservableObject services
- **Reactive Updates**: SwiftUI's @Published properties for automatic UI updates
- **Async/Await**: Modern concurrency for network operations
- **Type Safety**: Strong typing with Codable for data serialization

---

## Database Integration

The application connects to the same Supabase PostgreSQL database as the web application, ensuring:

- **Unified Data**: Users can access their habits and progress from any platform
- **Real-time Sync**: Changes made on iOS instantly reflect on web and vice versa
- **Shared Authentication**: Single sign-on across all platforms
- **Consistent Schema**: Data models match the web application's database structure

### Database Tables

- `profiles`: User profile information
- `habits`: Habit definitions with weekly targets
- `checkins`: Daily habit completion records
- `friendships`: Social connections between users
- `battles`: Competitive challenges (future feature)

---

## User Experience

### Navigation

The app features a tab-based navigation system with four main sections:

1. **Habits**: Manage and track daily habits
2. **Dashboard**: View statistics, streaks, and motivational content
3. **Calendar**: Visualize progress over time with heatmap
4. **Profile**: User account management and settings

### Visual Design

- **Dark Theme**: Optimized for low-light viewing
- **Color Scheme**: Red accents for primary actions, white for text
- **Typography**: System fonts for native iOS feel
- **Icons**: SF Symbols for consistent iconography

---

## Future Enhancements

### Planned Features

- **Friends System**: Social features for connecting with other users
- **Battles**: Weekly competitive challenges with leaderboards
- **Apple Watch App**: Simplified check-in interface for Apple Watch
- **Push Notifications**: Reminders and streak notifications
- **Offline Support**: Local caching with background sync

---

## Development Notes

This project demonstrates proficiency in:
- SwiftUI framework and declarative UI development
- Modern Swift concurrency (async/await)
- RESTful API integration
- Real-time data synchronization
- iOS app architecture and design patterns
- Cross-platform data sharing

---

## Platform Requirements

- **iOS**: 17.0 or later
- **Device**: iPhone (optimized for iPhone 15 Pro and newer)
- **Backend**: Supabase cloud service

---

**Built with SwiftUI and Supabase**
