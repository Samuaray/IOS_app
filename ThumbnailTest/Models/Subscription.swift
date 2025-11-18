//
//  Subscription.swift
//  ThumbnailTest
//
//  Subscription and in-app purchase models
//

import Foundation
import StoreKit

struct SubscriptionInfo: Codable {
    let tier: String
    let status: String
    let expiresAt: Date?
    let isTrial: Bool
    let trialEndsAt: Date?
    let canUpgrade: Bool
    let canDowngrade: Bool
    let nextBillingDate: Date?
    let features: SubscriptionFeatures

    enum CodingKeys: String, CodingKey {
        case tier
        case status
        case expiresAt = "expires_at"
        case isTrial = "is_trial"
        case trialEndsAt = "trial_ends_at"
        case canUpgrade = "can_upgrade"
        case canDowngrade = "can_downgrade"
        case nextBillingDate = "next_billing_date"
        case features
    }
}

struct SubscriptionFeatures: Codable {
    let unlimitedAnalyses: Bool
    let detailedScoring: Bool
    let performanceTracking: Bool
    let exportResults: Bool
    let prioritySupport: Bool

    enum CodingKeys: String, CodingKey {
        case unlimitedAnalyses = "unlimited_analyses"
        case detailedScoring = "detailed_scoring"
        case performanceTracking = "performance_tracking"
        case exportResults = "export_results"
        case prioritySupport = "priority_support"
    }
}

// MARK: - Subscription Product
struct SubscriptionProduct: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
    let product: Product?

    static let creator = SubscriptionProduct(
        id: "com.thumbnailtest.creator.monthly",
        name: "Creator",
        price: "$9.99",
        period: "month",
        features: [
            "Unlimited thumbnail analyses",
            "Detailed scoring breakdowns",
            "Performance tracking",
            "Export & share results",
            "Priority support"
        ],
        isPopular: true,
        product: nil
    )

    static let pro = SubscriptionProduct(
        id: "com.thumbnailtest.pro.monthly",
        name: "Pro",
        price: "$29.99",
        period: "month",
        features: [
            "Everything in Creator",
            "YouTube API integration",
            "Automatic CTR tracking",
            "Competitor analysis",
            "Trend alerts",
            "Team features (3 seats)"
        ],
        isPopular: false,
        product: nil
    )
}

// MARK: - Purchase State
enum PurchaseState {
    case notPurchased
    case purchasing
    case purchased
    case failed(Error)
    case restored
}

// MARK: - Subscription Error
enum SubscriptionError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case networkError

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .verificationFailed:
            return "Could not verify purchase"
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
