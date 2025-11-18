//
//  Constants.swift
//  ThumbnailTest
//
//  Global constants and configuration
//

import SwiftUI

struct Constants {
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://api.thumbnailtest.app/v1"
        static let stagingURL = "https://staging-api.thumbnailtest.app/v1"
        static let localURL = "http://localhost:3000/v1"

        // Use this to switch environments
        #if DEBUG
        static let currentURL = localURL
        #else
        static let currentURL = baseURL
        #endif

        static let timeout: TimeInterval = 30
    }

    // MARK: - App Configuration
    struct App {
        static let name = "ThumbnailTest"
        static let version = "1.0.0"
        static let minimumIOSVersion = "16.0"
    }

    // MARK: - Subscription Tiers
    struct Subscription {
        static let freeTierLimit = 3
        static let creatorMonthlyPrice = 9.99
        static let proMonthlyPrice = 29.99
        static let trialDurationDays = 7

        enum Tier: String {
            case free = "free"
            case creator = "creator"
            case pro = "pro"
        }
    }

    // MARK: - Analysis Configuration
    struct Analysis {
        static let minThumbnails = 2
        static let maxThumbnails = 4
        static let maxFileSize = 10_485_760 // 10MB in bytes
        static let minRecommendedWidth = 1280
        static let minRecommendedHeight = 720
        static let supportedFormats = ["jpg", "jpeg", "png", "heic"]
    }

    // MARK: - Categories
    static let categories = [
        "Gaming",
        "Tech & Software",
        "Lifestyle & Vlog",
        "Education & How-To",
        "Entertainment",
        "Business & Finance",
        "Health & Fitness",
        "Cooking & Food",
        "Other"
    ]

    // MARK: - Subscriber Ranges
    static let subscriberRanges = [
        "<1K",
        "1K-10K",
        "10K-50K",
        "50K-100K",
        "100K+"
    ]
}

// MARK: - Design System
extension Constants {
    struct Colors {
        // Primary
        static let primaryRed = Color(hex: "#FF0050")
        static let primaryDark = Color(hex: "#282828")

        // Semantic
        static let successGreen = Color(hex: "#00D26A")
        static let warningOrange = Color(hex: "#FFB800")
        static let errorRed = Color(hex: "#FF3B30")

        // Backgrounds
        static let backgroundLight = Color.white
        static let backgroundDark = Color(hex: "#1C1C1E")
        static let cardBackground = Color(hex: "#F5F5F5")
        static let cardBackgroundDark = Color(hex: "#2C2C2E")

        // Text
        static let textPrimary = Color.black
        static let textPrimaryDark = Color.white
        static let textSecondary = Color(hex: "#8E8E93")

        // Score Gradients
        static let scoreVeryLow = [Color(hex: "#FF3B30"), Color(hex: "#FF6B30")] // 0-40
        static let scoreLow = [Color(hex: "#FFB800"), Color(hex: "#FFA800")] // 41-70
        static let scoreGood = [Color(hex: "#007AFF"), Color(hex: "#0056D6")] // 71-85
        static let scoreExcellent = [Color(hex: "#00D26A"), Color(hex: "#00B85C")] // 86-100
    }

    struct Typography {
        static let headlineXL = Font.system(size: 34, weight: .bold)
        static let headlineLarge = Font.system(size: 28, weight: .bold)
        static let headlineMedium = Font.system(size: 22, weight: .semibold)
        static let headlineSmall = Font.system(size: 18, weight: .semibold)

        static let bodyLarge = Font.system(size: 17, weight: .regular)
        static let bodyMedium = Font.system(size: 15, weight: .regular)
        static let bodySmall = Font.system(size: 13, weight: .regular)

        static let captionLarge = Font.system(size: 12, weight: .medium)
        static let captionSmall = Font.system(size: 11, weight: .regular)
    }

    struct Spacing {
        static let spacing2: CGFloat = 2
        static let spacing4: CGFloat = 4
        static let spacing8: CGFloat = 8
        static let spacing12: CGFloat = 12
        static let spacing16: CGFloat = 16
        static let spacing20: CGFloat = 20
        static let spacing24: CGFloat = 24
        static let spacing32: CGFloat = 32
        static let spacing40: CGFloat = 40
    }

    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let full: CGFloat = 999
    }

    struct Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let dark = Color.black.opacity(0.15)
    }
}
