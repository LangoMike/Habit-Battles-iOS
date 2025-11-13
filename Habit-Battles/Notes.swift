//
//  Notes.swift
//  Habit-Battles
//
//  Created by Mike Gweth Lango on 11/12/25.
//

Habit-Battles
/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:13:7 Type 'AuthService' does not conform to protocol 'ObservableObject'

/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:14:6 Initializer 'init(wrappedValue:)' is not available due to missing import of defining module 'Combine'

/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:15:6 Initializer 'init(wrappedValue:)' is not available due to missing import of defining module 'Combine'

/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:16:6 Initializer 'init(wrappedValue:)' is not available due to missing import of defining module 'Combine'

/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:34:16 Initializer for conditional binding must have Optional type, not 'User'

/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:86:20 Cannot convert return expression of type '@Sendable (String?) async throws -> User' to return type 'User'

/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift:43:13 Expected pattern
        let { data: checkinData, error: checkinError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift:70:13 Expected pattern
        let { data: habitData, error: habitError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:29:13 Expected pattern
        let { data: habitsData, error: habitsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:57:13 Expected pattern
        let { data: weekCheckins, error: weekError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:67:13 Expected pattern
        let { data: todayCheckins } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:121:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:145:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:164:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:186:13 Expected pattern
        let { data: existing, error: checkError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:218:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:26:13 Expected pattern
        let { data: existingProfile, error: fetchError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:56:13 Expected pattern
        let { error: insertError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:74:13 Expected pattern
        let { data, error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:101:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:45:13 Expected pattern
        let { data: habitsData, error: habitsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:84:13 Expected pattern
        let { data: weekCheckins, error: checkinsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:94:13 Expected pattern
        let { data: totalCheckins } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:134:13 Expected pattern
        let { data: checkinsData, error } = try await supabase
            ^
ERROR 2:

Habit-Battles
/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/AuthService.swift:9:8 Unable to find module dependency: 'Supabase'
import Supabase
       ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift:43:13 Expected pattern
        let { data: checkinData, error: checkinError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/CalendarService.swift:70:13 Expected pattern
        let { data: habitData, error: habitError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:29:13 Expected pattern
        let { data: habitsData, error: habitsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:57:13 Expected pattern
        let { data: weekCheckins, error: weekError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:67:13 Expected pattern
        let { data: todayCheckins } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:121:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:145:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:164:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:186:13 Expected pattern
        let { data: existing, error: checkError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/HabitService.swift:218:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:26:13 Expected pattern
        let { data: existingProfile, error: fetchError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:56:13 Expected pattern
        let { error: insertError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:74:13 Expected pattern
        let { data, error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/ProfileService.swift:101:13 Expected pattern
        let { error } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift
/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:45:13 Expected pattern
        let { data: habitsData, error: habitsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:84:13 Expected pattern
        let { data: weekCheckins, error: checkinsError } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:94:13 Expected pattern
        let { data: totalCheckins } = try await supabase
            ^

/Users/langomike/Habit-Battles/Habit-Battles/Services/StatsService.swift:134:13 Expected pattern
        let { data: checkinsData, error } = try await supabase
            ^
