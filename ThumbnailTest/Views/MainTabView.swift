//
//  MainTabView.swift
//  ThumbnailTest
//
//  Main tab navigation container
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var showingNewAnalysis = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // New Analysis Tab (Dummy - triggers sheet)
            Color.clear
                .tabItem {
                    Label("Analyze", systemImage: "plus.circle.fill")
                }
                .tag(1)

            // History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)

            // Settings Tab
            Text("Settings - Coming Soon")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(Constants.Colors.primaryRed)
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                showingNewAnalysis = true
                // Reset to home tab
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showingNewAnalysis) {
            NewAnalysisView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
