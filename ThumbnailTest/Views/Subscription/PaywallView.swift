//
//  PaywallView.swift
//  ThumbnailTest
//
//  Premium subscription paywall
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.spacing32) {
                    // Header
                    VStack(spacing: Constants.Spacing.spacing16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Constants.Colors.primaryRed)

                        Text("Unlock Unlimited")
                            .font(Constants.Typography.headlineLarge)
                            .fontWeight(.bold)

                        Text("You've reached your free analysis limit.\nUpgrade for unlimited analyses!")
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Constants.Spacing.spacing24)

                    // Features list
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing16) {
                        FeatureRow(
                            icon: "infinity",
                            title: "Unlimited Analyses",
                            description: "Test as many thumbnails as you want"
                        )

                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "Detailed Scoring",
                            description: "Get 5 factor scores for every thumbnail"
                        )

                        FeatureRow(
                            icon: "clock.arrow.circlepath",
                            title: "Performance Tracking",
                            description: "Track actual CTR vs predictions"
                        )

                        FeatureRow(
                            icon: "square.and.arrow.up",
                            title: "Export & Share",
                            description: "Share results with your team"
                        )

                        FeatureRow(
                            icon: "star.fill",
                            title: "Priority Support",
                            description: "Get help when you need it"
                        )
                    }
                    .padding()
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.CornerRadius.large)

                    // Product cards
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        VStack(spacing: Constants.Spacing.spacing16) {
                            ForEach(viewModel.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isPopular: product.id == "com.thumbnailtest.creator.monthly",
                                    isPurchasing: viewModel.isPurchasing
                                ) {
                                    Task {
                                        await viewModel.purchase(product)
                                    }
                                }
                            }
                        }
                    }

                    // Restore purchases button
                    Button(action: {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    .disabled(viewModel.isLoading)

                    // Terms
                    VStack(spacing: Constants.Spacing.spacing8) {
                        Text("7-day free trial, then automatically renews")
                            .font(Constants.Typography.captionLarge)
                            .foregroundColor(Constants.Colors.textSecondary)

                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // TODO: Open terms
                            }
                            Text("•")
                            Button("Privacy Policy") {
                                // TODO: Open privacy
                            }
                        }
                        .font(Constants.Typography.captionLarge)
                        .foregroundColor(Constants.Colors.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Constants.Spacing.spacing24)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                }
            }
            .alert("Success!", isPresented: $viewModel.showSuccessMessage) {
                Button("Continue") {
                    dismiss()
                }
            } message: {
                Text("You now have unlimited access to all premium features!")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: Constants.Spacing.spacing16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Constants.Colors.primaryRed)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.bodyMedium)
                    .fontWeight(.semibold)

                Text(description)
                    .font(Constants.Typography.bodySmall)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isPopular: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing16) {
            // Popular badge
            if isPopular {
                HStack {
                    Spacer()
                    Text("MOST POPULAR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.primaryRed)
                        .cornerRadius(4)
                    Spacer()
                }
            }

            // Product info
            VStack(spacing: Constants.Spacing.spacing8) {
                Text(productName)
                    .font(Constants.Typography.headlineSmall)
                    .fontWeight(.bold)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.displayPrice)
                        .font(Constants.Typography.headlineMedium)
                        .fontWeight(.bold)
                    Text("/month")
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(Constants.Colors.textSecondary)
                }

                if isPopular {
                    Text("Start with 7-day free trial")
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(Constants.Colors.successGreen)
                        .fontWeight(.medium)
                }
            }

            // Purchase button
            Button(action: onPurchase) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isPopular ? "Start Free Trial" : "Subscribe")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(.white)
                .background(Constants.Colors.primaryRed)
                .cornerRadius(Constants.CornerRadius.medium)
            }
            .disabled(isPurchasing)
        }
        .padding(Constants.Spacing.spacing20)
        .background(Color.white)
        .cornerRadius(Constants.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .stroke(
                    isPopular ? Constants.Colors.primaryRed : Color.gray.opacity(0.2),
                    lineWidth: isPopular ? 2 : 1
                )
        )
        .shadow(
            color: isPopular ? Constants.Colors.primaryRed.opacity(0.2) : Constants.Shadow.light,
            radius: isPopular ? 12 : 4,
            x: 0,
            y: isPopular ? 4 : 2
        )
    }

    private var productName: String {
        if product.id.contains("creator") {
            return "Creator Plan"
        } else if product.id.contains("pro") {
            return "Pro Plan"
        } else {
            return "Premium Plan"
        }
    }
}

#Preview {
    PaywallView()
}
