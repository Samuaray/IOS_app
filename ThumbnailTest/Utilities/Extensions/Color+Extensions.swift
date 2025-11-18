//
//  Color+Extensions.swift
//  ThumbnailTest
//
//  Extensions for Color to support hex values and score gradients
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex string (e.g., "#FF0050" or "FF0050")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Get gradient colors based on score value
    /// - Parameter score: Score value (0-100)
    /// - Returns: Array of colors for gradient
    static func scoreGradient(for score: Int) -> [Color] {
        switch score {
        case 0...40:
            return Constants.Colors.scoreVeryLow
        case 41...70:
            return Constants.Colors.scoreLow
        case 71...85:
            return Constants.Colors.scoreGood
        case 86...100:
            return Constants.Colors.scoreExcellent
        default:
            return Constants.Colors.scoreLow
        }
    }

    /// Get single color based on score value
    /// - Parameter score: Score value (0-100)
    /// - Returns: Primary color for the score
    static func scoreColor(for score: Int) -> Color {
        return scoreGradient(for: score)[0]
    }
}
