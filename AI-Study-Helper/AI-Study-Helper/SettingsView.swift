//
//  SettingsView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var apiKey = ""
    @State private var showingSavedAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Key")) {
                    SecureField("OpenAI API Key", text: $apiKey)
                    
                    Button("Save API Key") {
                        dataManager.saveAPIKey(apiKey)
                        showingSavedAlert = true
                    }
                    .disabled(apiKey.isEmpty)
                }
                
                Section(header: Text("About")) {
                    Text("This app allows you to create and study flashcards organized by topics. You can also generate exam cards using AI.")
                }
                
                Section(header: Text("App Statistics")) {
                    HStack {
                        Text("Total Topics")
                        Spacer()
                        Text("\(dataManager.topics.count)")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Total Flashcards")
                        Spacer()
                        Text("\(dataManager.flashcards.count)")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                apiKey = dataManager.apiKey
            }
            .alert("API Key Saved", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
