//
//  Analysis.swift
//  ThumbnailTest
//
//  Analysis model containing multiple thumbnails
//

import Foundation

struct Analysis: Codable, Identifiable {
    let id: String
    let userId: String

    // Analysis details
    var videoTitle: String?
    var category: String?
    var notes: String?

    // Status
    var status: AnalysisStatus
    var published: Bool
    var publishedAt: Date?

    // Performance tracking
    var youtubeVideoId: String?
    var youtubeVideoUrl: String?
    var actualCTR: Double?
    var actualViews: Int?
    var selectedThumbnailId: String?

    // Thumbnails
    var thumbnails: [Thumbnail]

    // Metadata
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case videoTitle = "video_title"
        case category
        case notes
        case status
        case published
        case publishedAt = "published_at"
        case youtubeVideoId = "youtube_video_id"
        case youtubeVideoUrl = "youtube_video_url"
        case actualCTR = "actual_ctr"
        case actualViews = "actual_views"
        case selectedThumbnailId = "selected_thumbnail_id"
        case thumbnails
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Computed Properties

    var winner: Thumbnail? {
        thumbnails.first(where: { $0.isWinner })
    }

    var selectedThumbnail: Thumbnail? {
        if let selectedId = selectedThumbnailId {
            return thumbnails.first(where: { $0.id == selectedId })
        }
        return nil
    }

    var displayTitle: String {
        videoTitle ?? "Untitled Analysis"
    }

    var displayCategory: String {
        category ?? "Uncategorized"
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    var statusBadgeText: String {
        if published {
            return "Published"
        } else {
            return status.rawValue.capitalized
        }
    }

    var averageScore: Int {
        let scores = thumbnails.compactMap { $0.overallScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    var accuracy: Double? {
        guard let actualCTR = actualCTR,
              let predictedCTR = winner?.predictedCTR else {
            return nil
        }
        let difference = abs(actualCTR - predictedCTR)
        let accuracy = max(0, 100 - (difference / predictedCTR * 100))
        return accuracy
    }
}

// MARK: - Analysis Status
enum AnalysisStatus: String, Codable {
    case draft = "draft"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
}

// MARK: - Mock Data
extension Analysis {
    static let mock = Analysis(
        id: "analysis-1",
        userId: "user-1",
        videoTitle: "How to Build iOS Apps in 2025",
        category: "Education & How-To",
        notes: "Testing face vs no-face variants",
        status: .completed,
        published: false,
        publishedAt: nil,
        youtubeVideoId: nil,
        youtubeVideoUrl: nil,
        actualCTR: nil,
        actualViews: nil,
        selectedThumbnailId: nil,
        thumbnails: [Thumbnail.mock, Thumbnail.mock2],
        createdAt: Date(),
        updatedAt: Date()
    )

    static let mockPublished = Analysis(
        id: "analysis-2",
        userId: "user-1",
        videoTitle: "React Native Complete Guide",
        category: "Education & How-To",
        notes: "Final comparison",
        status: .completed,
        published: true,
        publishedAt: Date().addingTimeInterval(-86400),
        youtubeVideoId: "abc123",
        youtubeVideoUrl: "https://youtube.com/watch?v=abc123",
        actualCTR: 7.8,
        actualViews: 15000,
        selectedThumbnailId: "thumb-1",
        thumbnails: [Thumbnail.mock],
        createdAt: Date().addingTimeInterval(-86400 * 2),
        updatedAt: Date().addingTimeInterval(-86400)
    )
}
