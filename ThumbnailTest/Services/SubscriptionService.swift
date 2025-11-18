//
//  SubscriptionService.swift
//  ThumbnailTest
//
//  StoreKit 2 subscription management service
//

import Foundation
import StoreKit

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    // Product IDs (must match App Store Connect)
    private let productIDs = [
        "com.thumbnailtest.creator.monthly",
        "com.thumbnailtest.pro.monthly"
    ]

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var subscriptionStatus: SubscriptionStatus?

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Verify the transaction
            let transaction = try checkVerified(verification)

            // Update subscription status
            await updateSubscriptionStatus()

            // Finish the transaction
            await transaction.finish()

            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        // Sync with the App Store
        try await AppStore.sync()

        // Update status
        await updateSubscriptionStatus()
    }

    // MARK: - Check Subscription Status

    func updateSubscriptionStatus() async {
        var highestStatus: SubscriptionStatus?

        // Check all product statuses
        for product in products {
            guard let status = try? await product.subscription?.status else {
                continue
            }

            for subscription in status {
                // Check if verified
                guard case .verified(let renewalInfo) = subscription.renewalInfo,
                      case .verified(let transaction) = subscription.transaction else {
                    continue
                }

                // Update purchased IDs
                if subscription.state == .subscribed || subscription.state == .inGracePeriod {
                    purchasedProductIDs.insert(transaction.productID)

                    // Create status
                    let newStatus = SubscriptionStatus(
                        productID: transaction.productID,
                        state: subscription.state,
                        renewalInfo: renewalInfo,
                        transaction: transaction
                    )

                    // Keep the highest tier subscription
                    if highestStatus == nil || newStatus.tier > highestStatus!.tier {
                        highestStatus = newStatus
                    }
                } else {
                    purchasedProductIDs.remove(transaction.productID)
                }
            }
        }

        subscriptionStatus = highestStatus
    }

    // MARK: - Listen for Transactions

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to purchase()
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Update subscription status
                    await self.updateSubscriptionStatus()

                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helper Methods

    func isSubscribed(to productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }

    var hasActiveSubscription: Bool {
        return !purchasedProductIDs.isEmpty
    }

    var currentTier: SubscriptionTier {
        if isSubscribed(to: "com.thumbnailtest.pro.monthly") {
            return .pro
        } else if isSubscribed(to: "com.thumbnailtest.creator.monthly") {
            return .creator
        } else {
            return .free
        }
    }
}

// MARK: - Subscription Status

struct SubscriptionStatus {
    let productID: String
    let state: Product.SubscriptionInfo.Status.State
    let renewalInfo: Product.SubscriptionInfo.RenewalInfo
    let transaction: Transaction

    var tier: Int {
        switch productID {
        case "com.thumbnailtest.pro.monthly":
            return 2
        case "com.thumbnailtest.creator.monthly":
            return 1
        default:
            return 0
        }
    }

    var expirationDate: Date? {
        return transaction.expirationDate
    }

    var willRenew: Bool {
        return renewalInfo.willAutoRenew
    }

    var isInGracePeriod: Bool {
        return state == .inGracePeriod
    }

    var displayName: String {
        switch productID {
        case "com.thumbnailtest.pro.monthly":
            return "Pro"
        case "com.thumbnailtest.creator.monthly":
            return "Creator"
        default:
            return "Free"
        }
    }
}

// MARK: - Subscription Tier

enum SubscriptionTier: String {
    case free = "free"
    case creator = "creator"
    case pro = "pro"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .creator: return "Creator"
        case .pro: return "Pro"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "3 analyses per month",
                "Basic scoring",
                "History access"
            ]
        case .creator:
            return [
                "Unlimited analyses",
                "Detailed scoring breakdowns",
                "Performance tracking",
                "Export & share results",
                "Priority support"
            ]
        case .pro:
            return [
                "Everything in Creator",
                "YouTube API integration",
                "Automatic CTR tracking",
                "Competitor analysis",
                "Trend alerts",
                "Team features (3 seats)"
            ]
        }
    }
}

// MARK: - Store Error

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found in the App Store"
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        }
    }
}
