//
//  AddCardView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct AddCardView: View {
    let topicID: UUID
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var question = ""
    @State private var answer = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextEditor(text: $question)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Answer")) {
                    TextEditor(text: $answer)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Flashcard")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !question.isEmpty && !answer.isEmpty {
                        dataManager.addFlashcard(question: question, answer: answer, topicID: topicID)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(question.isEmpty || answer.isEmpty)
            )
        }
    }
}
