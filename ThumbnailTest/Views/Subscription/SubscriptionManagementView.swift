//
//  SubscriptionManagementView.swift
//  ThumbnailTest
//
//  Subscription management and details screen
//

import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingPaywall = false

    var body: some View {
        List {
            // Current Plan Section
            Section {
                if let user = authViewModel.currentUser {
                    CurrentPlanCard(user: user, viewModel: viewModel)
                }
            }

            // Usage Section (for free tier)
            if let user = authViewModel.currentUser, user.isFreeTier {
                Section("This Month") {
                    UsageRow(
                        title: "Analyses Used",
                        value: "\(user.analysesThisMonth) of \(Constants.Subscription.freeTierLimit)",
                        progress: Double(user.analysesThisMonth) / Double(Constants.Subscription.freeTierLimit)
                    )

                    HStack {
                        Text("Resets")
                            .foregroundColor(Constants.Colors.textSecondary)
                        Spacer()
                        Text(formattedResetDate(user.analysesResetAt))
                            .foregroundColor(Constants.Colors.textPrimary)
                    }
                    .font(Constants.Typography.bodyMedium)
                }
            }

            // Subscription Status (for paid tiers)
            if let status = viewModel.subscriptionStatus {
                Section("Subscription Details") {
                    HStack {
                        Text("Plan")
                        Spacer()
                        Text(status.displayName)
                            .fontWeight(.semibold)
                    }

                    if let expirationDate = status.expirationDate {
                        HStack {
                            Text(status.willRenew ? "Renews" : "Expires")
                            Spacer()
                            Text(formattedDate(expirationDate))
                        }
                    }

                    if status.isInGracePeriod {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(Constants.Colors.warningOrange)
                            Text("Payment Issue - Grace Period")
                                .foregroundColor(Constants.Colors.warningOrange)
                        }
                    }

                    Button("Manage Subscription") {
                        openSubscriptionManagement()
                    }
                    .foregroundColor(Constants.Colors.primaryRed)
                }
            }

            // Features Section
            Section("Features") {
                ForEach(currentFeatures, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.successGreen)
                        Text(feature)
                    }
                }
            }

            // Upgrade/Restore Section
            Section {
                if !viewModel.hasActiveSubscription {
                    Button(action: {
                        showingPaywall = true
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(Constants.Colors.primaryRed)
                            Text("Upgrade to Premium")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Button(action: {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        Text("Restore Purchases")
                            .foregroundColor(Constants.Colors.textPrimary)
                    }
                }
                .disabled(viewModel.isLoading)
            }

            // Support Section
            Section {
                Link(destination: URL(string: "https://thumbnailtest.app/support")!) {
                    HStack {
                        Text("Contact Support")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                }

                Link(destination: URL(string: "https://thumbnailtest.app/faq")!) {
                    HStack {
                        Text("FAQ")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("Success", isPresented: $viewModel.showSuccessMessage) {
            Button("OK") {}
        } message: {
            Text("Subscription restored successfully!")
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

    // MARK: - Helpers

    private var currentFeatures: [String] {
        viewModel.currentTier.features
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedResetDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func openSubscriptionManagement() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                try? await AppStore.showManageSubscriptions(in: scene)
            }
        }
    }
}

// MARK: - Current Plan Card
struct CurrentPlanCard: View {
    let user: User
    let viewModel: SubscriptionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Plan")
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(Constants.Colors.textSecondary)

                    HStack(spacing: 8) {
                        if !user.isFreeTier {
                            Image(systemName: "crown.fill")
                                .foregroundColor(Constants.Colors.primaryRed)
                        }
                        Text(user.subscriptionDisplayName)
                            .font(Constants.Typography.headlineSmall)
                            .fontWeight(.bold)
                    }
                }

                Spacer()

                if user.isFreeTier {
                    Text("FREE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray)
                        .cornerRadius(4)
                } else {
                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.primaryRed)
                        .cornerRadius(4)
                }
            }

            if user.isFreeTier {
                Text("Upgrade for unlimited analyses and premium features")
                    .font(Constants.Typography.bodySmall)
                    .foregroundColor(Constants.Colors.textSecondary)
            } else {
                Text("You have full access to all premium features")
                    .font(Constants.Typography.bodySmall)
                    .foregroundColor(Constants.Colors.successGreen)
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
}

// MARK: - Usage Row
struct UsageRow: View {
    let title: String
    let value: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .fontWeight(.semibold)
            }
            .font(Constants.Typography.bodyMedium)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: progress >= 1.0 ?
                                    [Constants.Colors.errorRed] :
                                    [Constants.Colors.primaryRed, Constants.Colors.primaryRed.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionManagementView()
            .environmentObject(AuthViewModel())
    }
}
