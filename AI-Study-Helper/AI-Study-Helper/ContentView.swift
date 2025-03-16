//
//  ContentView.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TopicsView()
                .environmentObject(dataManager)
                .tabItem {
                    Label("Topics", systemImage: "folder")
                }
                .tag(0)
            
            SettingsView()
                .environmentObject(dataManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}
