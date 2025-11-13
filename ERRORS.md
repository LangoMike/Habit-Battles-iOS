/Users/8789017/Documents/Habit-Battles-iOS/Habit-Battles/Views/Calendar/CalendarView.swift:107:10 'onChange(of:perform:)' was deprecated in iOS 17.0: Use `onChange` with a two or zero parameter action closure instead.
/Users/8789017/Documents/Habit-Battles-iOS/Habit-Battles/Views/Calendar/CalendarView.swift:112:10 'onChange(of:perform:)' was deprecated in iOS 17.0: Use `onChange` with a two or zero parameter action closure instead.
/Users/8789017/Documents/Habit-Battles-iOS/Habit-Battles/Views/Calendar/CalendarView.swift:128:19 Constant 'calendarTask' inferred to have type '()', which may be unexpected
/Users/8789017/Documents/Habit-Battles-iOS/Habit-Battles/Views/Dashboard/MotivationalQuoteView.swift:123:13 No 'async' operations occur within 'await' expression

Errors after running build:
Initial session emitted after attempting to refresh the local stored session.
This is incorrect behavior and will be fixed in the next major release since it's a breaking change.
To opt-in to the new behavior now, set `emitLocalSessionAsInitialSession: true` in your AuthClient configuration.
The new behavior ensures that the locally stored session is always emitted, regardless of its validity or expiration.
If you rely on the initial session to opt users in, you need to add an additional check for `session.isExpired` in the session.

Check https://github.com/supabase/supabase-swift/pull/822 for more information.


Failed to build debug session: keyNotFound(CodingKeys(stringValue: "createdAt", intValue: nil), Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key CodingKeys(stringValue: \"createdAt\", intValue: nil) (\"createdAt\").", underlyingError: nil))
