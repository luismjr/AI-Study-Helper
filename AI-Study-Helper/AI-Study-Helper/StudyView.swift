//
//  StudyView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct StudyView: View {
    let cards: [Flashcard]
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if cards.isEmpty {
                    Text("No flashcards available to study")
                        .font(.headline)
                        .padding()
                } else {
                    // Card counter
                    Text("\(currentIndex + 1) of \(cards.count)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    // Card View
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                        
                        VStack {
                            Text(showingAnswer ? "Answer" : "Question")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Text(showingAnswer ? cards[currentIndex].answer : cards[currentIndex].question)
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .animation(.easeInOut, value: showingAnswer)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(height: 300)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            showingAnswer.toggle()
                        }
                    }
                    
                    Text("Tap card to flip")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                showingAnswer = false
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(currentIndex > 0 ? .blue : .gray)
                        }
                        .disabled(currentIndex == 0)
                        .padding()
                        
                        Button(action: {
                            if currentIndex < cards.count - 1 {
                                currentIndex += 1
                                showingAnswer = false
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(currentIndex < cards.count - 1 ? .blue : .gray)
                        }
                        .disabled(currentIndex == cards.count - 1)
                        .padding()
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Study Cards")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
