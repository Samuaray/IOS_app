//
//  ThumbnailTestApp.swift
//  ThumbnailTest
//
//  Created by Claude Code
//  Copyright © 2025 ThumbnailTest. All rights reserved.
//

import SwiftUI

@main
struct ThumbnailTestApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
