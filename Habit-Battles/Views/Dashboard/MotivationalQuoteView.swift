//
//  MotivationalQuoteView.swift
//  Habit-Battles
//
//  Motivational quote component with API integration
//

import SwiftUI

struct MotivationalQuote: Codable {
    let _id: String
    let content: String
    let author: String
    let tags: [String]
}

struct MotivationalQuoteView: View {
    @State private var quote: MotivationalQuote?
    @State private var isLoading = true
    
    // Fallback quotes in case API fails
    private let fallbackQuotes: [MotivationalQuote] = [
        MotivationalQuote(
            _id: "fallback1",
            content: "The only way to do great work is to love what you do.",
            author: "Steve Jobs",
            tags: ["motivation"]
        ),
        MotivationalQuote(
            _id: "fallback2",
            content: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            author: "Winston Churchill",
            tags: ["motivation"]
        ),
        MotivationalQuote(
            _id: "fallback3",
            content: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt",
            tags: ["motivation"]
        ),
        MotivationalQuote(
            _id: "fallback4",
            content: "Don't watch the clock; do what it does. Keep going.",
            author: "Sam Levenson",
            tags: ["motivation"]
        ),
        MotivationalQuote(
            _id: "fallback5",
            content: "The only limit to our realization of tomorrow is our doubts of today.",
            author: "Franklin D. Roosevelt",
            tags: ["motivation"]
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.red)
                
                Text("Daily Motivation")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
            }
            
            if isLoading {
                // Loading state
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color.red.opacity(0.2))
                        .frame(height: 16)
                        .cornerRadius(4)
                    Rectangle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 200, height: 16)
                        .cornerRadius(4)
                }
            } else if let quote = quote {
                // Quote content
                VStack(alignment: .leading, spacing: 12) {
                    Text("\"\(quote.content)\"")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Text("— \(quote.author)")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .italic()
                        
                        Spacer()
                        
                        Button(action: fetchQuote) {
                            Text("New Quote")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.red.opacity(0.2), Color.red.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .task {
            await fetchQuote()
        }
    }
    
    /// Fetch a new motivational quote from API
    private func fetchQuote() {
        Task {
            isLoading = true
            
            do {
                // Try to fetch from API with timeout
                let url = URL(string: "https://api.quotable.io/quotes/random?tags=motivation|success|inspiration&maxLength=150")!
                let (data, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let quotes = try? JSONDecoder().decode([MotivationalQuote].self, from: data),
                   let firstQuote = quotes.first {
                    quote = firstQuote
                } else {
                    throw NSError(domain: "QuoteError", code: 1)
                }
            } catch {
                // Use fallback quote
                quote = fallbackQuotes.randomElement()
            }
            
            isLoading = false
        }
    }
}

#Preview {
    MotivationalQuoteView()
        .padding()
        .background(Color.black)
}



