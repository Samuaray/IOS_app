//
//  MainTabView.swift
//  ThumbnailTest
//
//  Main tab navigation container
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // New Analysis Tab
            Text("New Analysis")
                .tabItem {
                    Label("Analyze", systemImage: "plus.circle.fill")
                }
                .tag(1)

            // History Tab
            Text("History")
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)

            // Settings Tab
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(Constants.Colors.primaryRed)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
