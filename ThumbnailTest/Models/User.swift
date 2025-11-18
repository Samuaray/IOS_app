//
//  User.swift
//  ThumbnailTest
//
//  User model matching backend schema
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var fullName: String?
    var channelName: String?
    var contentNiche: String?
    var subscriberRange: String?
    var uploadFrequency: String?

    // Subscription
    var subscriptionTier: String
    var subscriptionStatus: String
    var subscriptionExpiresAt: Date?

    // Usage tracking
    var analysesThisMonth: Int
    var analysesResetAt: Date

    // Metadata
    let createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case channelName = "channel_name"
        case contentNiche = "content_niche"
        case subscriberRange = "subscriber_range"
        case uploadFrequency = "upload_frequency"
        case subscriptionTier = "subscription_tier"
        case subscriptionStatus = "subscription_status"
        case subscriptionExpiresAt = "subscription_expires_at"
        case analysesThisMonth = "analyses_this_month"
        case analysesResetAt = "analyses_reset_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLoginAt = "last_login_at"
    }

    // MARK: - Computed Properties

    var isFreeTier: Bool {
        subscriptionTier == "free"
    }

    var isPaidTier: Bool {
        subscriptionTier == "creator" || subscriptionTier == "pro"
    }

    var hasReachedLimit: Bool {
        isFreeTier && analysesThisMonth >= Constants.Subscription.freeTierLimit
    }

    var remainingAnalyses: Int {
        guard isFreeTier else { return Int.max }
        return max(0, Constants.Subscription.freeTierLimit - analysesThisMonth)
    }

    var subscriptionDisplayName: String {
        switch subscriptionTier {
        case "free":
            return "Free"
        case "creator":
            return "Creator"
        case "pro":
            return "Pro"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Mock Data for Previews
extension User {
    static let mock = User(
        id: "mock-user-id",
        email: "test@example.com",
        fullName: "John Doe",
        channelName: "Tech with John",
        contentNiche: "Education & How-To",
        subscriberRange: "10K-50K",
        uploadFrequency: "Weekly",
        subscriptionTier: "free",
        subscriptionStatus: "active",
        subscriptionExpiresAt: nil,
        analysesThisMonth: 1,
        analysesResetAt: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        lastLoginAt: Date()
    )

    static let mockPaid = User(
        id: "mock-paid-user-id",
        email: "creator@example.com",
        fullName: "Jane Creator",
        channelName: "Creator Channel",
        contentNiche: "Education & How-To",
        subscriberRange: "50K-100K",
        uploadFrequency: "Daily",
        subscriptionTier: "creator",
        subscriptionStatus: "active",
        subscriptionExpiresAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        analysesThisMonth: 25,
        analysesResetAt: Date(),
        createdAt: Date(),
        updatedAt: Date(),
        lastLoginAt: Date()
    )
}
