//
//  Thumbnail.swift
//  ThumbnailTest
//
//  Thumbnail model with AI analysis scores
//

import Foundation

struct Thumbnail: Codable, Identifiable {
    let id: String
    let analysisId: String

    // Image data
    let imageUrl: String
    let imageS3Key: String
    let orderIndex: Int

    // Scores (0-100)
    var overallScore: Int?
    var faceVisibilityScore: Int?
    var textReadabilityScore: Int?
    var colorContrastScore: Int?
    var visualClarityScore: Int?
    var emotionalImpactScore: Int?
    var predictedCTR: Double?

    // Analysis results
    var isWinner: Bool
    var isSelected: Bool
    var faceDetected: Bool?
    var textDetected: String?
    var recommendations: [String]?

    // Raw AI response
    var aiAnalysisRaw: [String: Any]?

    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case analysisId = "analysis_id"
        case imageUrl = "image_url"
        case imageS3Key = "image_s3_key"
        case orderIndex = "order_index"
        case overallScore = "overall_score"
        case faceVisibilityScore = "face_visibility_score"
        case textReadabilityScore = "text_readability_score"
        case colorContrastScore = "color_contrast_score"
        case visualClarityScore = "visual_clarity_score"
        case emotionalImpactScore = "emotional_impact_score"
        case predictedCTR = "predicted_ctr"
        case isWinner = "is_winner"
        case isSelected = "is_selected"
        case faceDetected = "face_detected"
        case textDetected = "text_detected"
        case recommendations
        case aiAnalysisRaw = "ai_analysis_raw"
        case createdAt = "created_at"
    }

    // MARK: - Computed Properties

    var scoreBreakdown: [ScoreItem] {
        [
            ScoreItem(name: "Face Visibility", score: faceVisibilityScore ?? 0, icon: "face.smiling"),
            ScoreItem(name: "Text Readability", score: textReadabilityScore ?? 0, icon: "text.alignleft"),
            ScoreItem(name: "Color Contrast", score: colorContrastScore ?? 0, icon: "paintpalette"),
            ScoreItem(name: "Visual Clarity", score: visualClarityScore ?? 0, icon: "eye"),
            ScoreItem(name: "Emotional Impact", score: emotionalImpactScore ?? 0, icon: "heart")
        ]
    }

    var hasScores: Bool {
        overallScore != nil
    }

    var displayCTR: String {
        guard let ctr = predictedCTR else { return "N/A" }
        return String(format: "%.1f%%", ctr)
    }
}

// MARK: - Score Item for Display
struct ScoreItem: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let icon: String
}

// MARK: - Mock Data
extension Thumbnail {
    static let mock = Thumbnail(
        id: "thumb-1",
        analysisId: "analysis-1",
        imageUrl: "https://example.com/thumb1.jpg",
        imageS3Key: "uploads/user-id/thumb1.jpg",
        orderIndex: 1,
        overallScore: 87,
        faceVisibilityScore: 95,
        textReadabilityScore: 82,
        colorContrastScore: 88,
        visualClarityScore: 90,
        emotionalImpactScore: 85,
        predictedCTR: 8.7,
        isWinner: true,
        isSelected: false,
        faceDetected: true,
        textDetected: "BUILD iOS APPS",
        recommendations: [
            "Excellent face visibility creates strong viewer connection",
            "Text could be 10% larger for better mobile readability",
            "Strong color contrast makes thumbnail stand out",
            "Facial expression conveys expertise and confidence"
        ],
        createdAt: Date()
    )

    static let mock2 = Thumbnail(
        id: "thumb-2",
        analysisId: "analysis-1",
        imageUrl: "https://example.com/thumb2.jpg",
        imageS3Key: "uploads/user-id/thumb2.jpg",
        orderIndex: 2,
        overallScore: 72,
        faceVisibilityScore: 0,
        textReadabilityScore: 88,
        colorContrastScore: 75,
        visualClarityScore: 85,
        emotionalImpactScore: 70,
        predictedCTR: 6.2,
        isWinner: false,
        isSelected: false,
        faceDetected: false,
        textDetected: "iOS Development Guide",
        recommendations: [
            "Consider adding a face for better emotional connection",
            "Text is readable but lacks visual hierarchy",
            "Color scheme is good but could be more bold",
            "Add element of surprise or curiosity"
        ],
        createdAt: Date()
    )
}
