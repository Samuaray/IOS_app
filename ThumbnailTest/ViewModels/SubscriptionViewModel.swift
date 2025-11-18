//
//  SubscriptionViewModel.swift
//  ThumbnailTest
//
//  Subscription UI state management
//

import Foundation
import StoreKit

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    @Published var showSuccessMessage = false
    @Published var currentTier: SubscriptionTier = .free

    private let subscriptionService = SubscriptionService.shared

    init() {
        loadProducts()
    }

    // MARK: - Load Products

    func loadProducts() {
        isLoading = true
        Task {
            await subscriptionService.loadProducts()
            products = subscriptionService.products
            updateCurrentTier()
            isLoading = false
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil

        do {
            let transaction = try await subscriptionService.purchase(product)

            if transaction != nil {
                showSuccessMessage = true
                updateCurrentTier()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    // MARK: - Restore

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await subscriptionService.restorePurchases()
            updateCurrentTier()

            if subscriptionService.hasActiveSubscription {
                showSuccessMessage = true
            } else {
                errorMessage = "No active subscriptions found"
            }
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func updateCurrentTier() {
        currentTier = subscriptionService.currentTier
    }

    var hasActiveSubscription: Bool {
        return subscriptionService.hasActiveSubscription
    }

    func isSubscribed(to productID: String) -> Bool {
        return subscriptionService.isSubscribed(to: productID)
    }

    var subscriptionStatus: SubscriptionStatus? {
        return subscriptionService.subscriptionStatus
    }

    // Get product by ID
    func product(for id: String) -> Product? {
        return products.first { $0.id == id }
    }

    // Format price
    func formattedPrice(for product: Product) -> String {
        return product.displayPrice
    }
}
