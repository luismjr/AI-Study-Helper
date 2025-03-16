//
//  OpenAIService.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-14.
//

import Foundation

class OpenAIService {
    private let apiKey = "YOUR_API_KEY_HERE"
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func generateFlashcards(for topic: String) async throws -> [String] {
        let prompt = "Generate 5 flashcards about \(topic). Each flashcard should have a question and an answer, formatted as 'Q: [question] A: [answer]'."

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 500
        ]

        let url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "OpenAIError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }

        return parseFlashcards(from: content)
    }

    private func parseFlashcards(from text: String) -> [String] {
        // Split the response into individual flashcards
        return text.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
}
