//
//  TopicsView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct TopicsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newTopicName = ""
    @State private var showingAddTopic = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.topics) { topic in
                    NavigationLink(destination: FlashcardsView(topic: topic)) {
                        HStack {
                            Text(topic.name)
                            Spacer()
                            Text("\(dataManager.flashcards.filter { $0.topicID == topic.id }.count) cards")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: dataManager.deleteTopic)
            }
            .navigationTitle("Flashcard Topics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTopic = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTopic) {
                AddTopicView()
                    .environmentObject(dataManager)
            }
        }
    }
}

