//
//  FlashcardsVIew.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct FlashcardsView: View {
    let topic: Topic
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddCard = false
    @State private var showingStudyMode = false
    @State private var showingExamMode = false
    @State private var isGeneratingExam = false
    @State private var showExamError = false
    
    var topicFlashcards: [Flashcard] {
        dataManager.flashcards.filter { $0.topicID == topic.id }
    }
    
    var body: some View {
        List {
            ForEach(topicFlashcards) { card in
                VStack(alignment: .leading) {
                    Text(card.question)
                        .font(.headline)
                    Text(card.answer)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                dataManager.deleteFlashcard(at: indexSet, for: topic.id)
            }
        }
        .navigationTitle(topic.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Label("Add Card", systemImage: "plus.card")
                    }
                    
                    Button(action: {
                        if !topicFlashcards.isEmpty {
                            showingStudyMode = true
                        }
                    }) {
                        Label("Study Cards", systemImage: "book")
                    }
                    .disabled(topicFlashcards.isEmpty)
                    
                    Button(action: {
                        if dataManager.apiKey.isEmpty {
                            showExamError = true
                        } else if !topicFlashcards.isEmpty {
                            Task {
                                isGeneratingExam = true
                                let success = await dataManager.generateExam(for: topic.id)
                                isGeneratingExam = false
                                if success {
                                    showingExamMode = true
                                } else {
                                    showExamError = true
                                }
                            }
                        } else {
                            showExamError = true
                        }
                    }) {
                        Label("Generate Exam", systemImage: "text.badge.star")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView(topicID: topic.id)
                .environmentObject(dataManager)
        }
        .fullScreenCover(isPresented: $showingStudyMode) {
            StudyView(cards: topicFlashcards)
        }
        .fullScreenCover(isPresented: $showingExamMode) {
            ExamView(cards: dataManager.examCards, topicName: topic.name)
        }
        .overlay {
            if isGeneratingExam {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Generating exam cards...")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10)
                }
                .ignoresSafeArea()
            }
        }
        .alert("Cannot Generate Exam", isPresented: $showExamError) {
            Button("OK", role: .cancel) { }
        } message: {
            if dataManager.apiKey.isEmpty {
                Text("Please enter your API key in Settings")
            } else if topicFlashcards.isEmpty {
                Text("You need to create flashcards first")
            } else {
                Text("Something went wrong. Please try again.")
            }
        }
    }
}
