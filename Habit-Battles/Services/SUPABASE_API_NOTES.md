# Supabase Swift SDK API Notes

## Important: API Compatibility

The Supabase Swift SDK API may vary slightly between versions. The code in this project uses common patterns, but you may need to adjust based on your installed SDK version.

## Common API Patterns Used

### Query Builder Pattern
```swift
let { data, error } = try await supabase
    .from("table_name")
    .select("*")
    .eq("column", value: "value")
    .execute()
```

### Insert Pattern
```swift
let { error } = try await supabase
    .from("table_name")
    .insert(jsonData)
    .execute()
```

### Update Pattern
```swift
let { error } = try await supabase
    .from("table_name")
    .update(jsonData)
    .eq("id", value: id)
    .execute()
```

### Delete Pattern
```swift
let { error } = try await supabase
    .from("table_name")
    .delete()
    .eq("id", value: id)
    .execute()
```

## Potential Adjustments Needed

1. **Method Names**: `.eq()` might be `.equals()` or `.filter()`
2. **Value Parameters**: Might need `.value()` wrapper or different syntax
3. **Execute**: Might be `.get()`, `.fetch()`, or implicit
4. **Error Handling**: Error types might differ
5. **Data Decoding**: Response format might need adjustment

## Testing After Package Installation

After adding the Supabase Swift package:
1. Build the project
2. Fix any compilation errors related to API differences
3. Test authentication flow
4. Test habit CRUD operations
5. Verify check-ins work correctly

## Resources

- [Supabase Swift SDK Docs](https://github.com/supabase/supabase-swift)
- Check the actual SDK version you install for exact API

