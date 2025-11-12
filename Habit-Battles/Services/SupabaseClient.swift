//
//  SupabaseClient.swift
//  Habit-Battles
//
//  Supabase client configuration and initialization
//

import Foundation
import Supabase

/// Singleton Supabase client for the app
/// Configure your Supabase URL and anon key in SupabaseConfig.swift
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Initialize Supabase client with configuration
        // These values should match your webapp's Supabase project
        let supabaseURL = SupabaseConfig.supabaseURL
        let supabaseAnonKey = SupabaseConfig.supabaseAnonKey
        
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
    }
}

/// Configuration file for Supabase credentials
/// Automatically configured via MCP connection
struct SupabaseConfig {
    // Supabase project URL and anon key from your project
    static let supabaseURL = "https://lphgqgixbssoeuftbcyp.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwaGdxZ2l4YnNzb2V1ZnRiY3lwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0ODQ2NDIsImV4cCI6MjA3MTA2MDY0Mn0.z85pE8JdhqtR-8E9BknU-vKRlia7r-C9x1t8GFqY_Pg"
}

