//
//  ContentView.swift
//  ThumbnailTest
//
//  Main navigation coordinator - routes between auth and main app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
