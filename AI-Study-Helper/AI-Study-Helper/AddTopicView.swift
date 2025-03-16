//
//  AddTopicView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct AddTopicView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var topicName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Topic")) {
                    TextField("Topic Name", text: $topicName)
                }
            }
            .navigationTitle("Add Topic")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !topicName.isEmpty {
                        dataManager.addTopic(name: topicName)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

