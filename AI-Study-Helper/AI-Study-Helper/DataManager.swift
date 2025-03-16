//
//  DataManager.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import Foundation

class DataManager: ObservableObject {
    @Published var topics: [Topic] = []
    @Published var flashcards: [Flashcard] = []
    @Published var examCards: [ExamCard] = []
    @Published var apiKey: String = ""
    
    private let topicsKey = "savedTopics"
    private let flashcardsKey = "savedFlashcards"
    private let apiKeyKey = "savedAPIKey"
    
    init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    func loadData() {
        if let topicsData = UserDefaults.standard.data(forKey: topicsKey),
           let decodedTopics = try? JSONDecoder().decode([Topic].self, from: topicsData) {
            topics = decodedTopics
        }
        
        if let flashcardsData = UserDefaults.standard.data(forKey: flashcardsKey),
           let decodedFlashcards = try? JSONDecoder().decode([Flashcard].self, from: flashcardsData) {
            flashcards = decodedFlashcards
        }
        
        apiKey = UserDefaults.standard.string(forKey: apiKeyKey) ?? ""
    }
    
    func saveData() {
        if let encodedTopics = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encodedTopics, forKey: topicsKey)
        }
        
        if let encodedFlashcards = try? JSONEncoder().encode(flashcards) {
            UserDefaults.standard.set(encodedFlashcards, forKey: flashcardsKey)
        }
        
        UserDefaults.standard.set(apiKey, forKey: apiKeyKey)
    }
    
    // MARK: - Topic Operations
    func addTopic(name: String) {
        let newTopic = Topic(name: name)
        topics.append(newTopic)
        saveData()
    }
    
    func deleteTopic(at offsets: IndexSet) {
        // Delete associated flashcards first
        for index in offsets {
            let topicID = topics[index].id
            flashcards.removeAll { $0.topicID == topicID }
        }
        
        topics.remove(atOffsets: offsets)
        saveData()
    }
    
    // MARK: - Flashcard Operations
    func addFlashcard(question: String, answer: String, topicID: UUID) {
        let newFlashcard = Flashcard(question: question, answer: answer, topicID: topicID)
        flashcards.append(newFlashcard)
        saveData()
    }
    
    func deleteFlashcard(at offsets: IndexSet, for topicID: UUID) {
        let topicFlashcards = flashcards.filter { $0.topicID == topicID }
        var allIndices: [Int] = []
        
        for offset in offsets {
            if let index = flashcards.firstIndex(where: { $0.id == topicFlashcards[offset].id }) {
                allIndices.append(index)
            }
        }
        
        for index in allIndices.sorted(by: >) {
            if index < flashcards.count {
                flashcards.remove(at: index)
            }
        }
        
        saveData()
    }
    
    // MARK: - API Key Management
    func saveAPIKey(_ key: String) {
        apiKey = key
        saveData()
    }
    
    // MARK: - Exam Generation
    func generateExam(for topicID: UUID) async -> Bool {
        guard let topic = topics.first(where: { $0.id == topicID }) else { return false }
        let topicFlashcards = flashcards.filter { $0.topicID == topicID }
        
        if apiKey.isEmpty || topicFlashcards.isEmpty {
            return false
        }
        
        // Create prompt based on existing flashcards
        var prompt = "Create 5 new flashcards for the topic '\(topic.name)'. Format as JSON array with 'question' and 'answer' fields. Here are examples of existing flashcards:\n"
        
        // Add examples (up to 3)
        let exampleCards = Array(topicFlashcards.prefix(3))
        for card in exampleCards {
            prompt += "Question: \(card.question)\nAnswer: \(card.answer)\n\n"
        }
        
        do {
            let generatedCards = try await generateCardsWithAI(prompt: prompt)
            
            DispatchQueue.main.async { [weak self] in
                self?.examCards = generatedCards
            }
            return true
        } catch {
            print("Error generating exam cards: \(error)")
            return false
        }
    }
    
    private func generateCardsWithAI(prompt: String) async throws -> [ExamCard] {
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that creates educational flashcards. Return only a JSON array."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse the response
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            
            // Extract JSON array from content
            if let jsonStart = content.range(of: "["),
               let jsonEnd = content.range(of: "]", options: .backwards) {
                
                let jsonContent = content[jsonStart.lowerBound...jsonEnd.upperBound]
                let jsonData = Data(jsonContent.utf8)
                
                if let cardsData = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: String]] {
                    return cardsData.compactMap { cardDict in
                        if let question = cardDict["question"], let answer = cardDict["answer"] {
                            return ExamCard(question: question, answer: answer)
                        }
                        return nil
                    }
                }
            }
        }
        
        throw NSError(domain: "FlashcardApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse AI response"])
    }
}
