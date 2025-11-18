//
//  HomeView.swift
//  ThumbnailTest
//
//  Home screen with stats and recent analyses
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var historyViewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.spacing24) {
                    // Header
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        if let user = authViewModel.currentUser {
                            Text("Hello, \(user.fullName ?? "Creator")!")
                                .font(Constants.Typography.headlineLarge)

                            if user.isFreeTier {
                                Text("\(user.remainingAnalyses) of 3 free analyses remaining")
                                    .font(Constants.Typography.bodyMedium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            } else {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(Constants.Colors.primaryRed)
                                    Text("\(user.subscriptionDisplayName) Plan")
                                        .foregroundColor(Constants.Colors.primaryRed)
                                }
                                .font(Constants.Typography.bodyMedium)
                                .fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                    // Primary CTA
                    Button(action: {
                        // TODO: Navigate to new analysis
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.title2)
                                    Text("Analyze New Thumbnails")
                                        .font(Constants.Typography.headlineSmall)
                                        .fontWeight(.semibold)
                                }

                                Text("Find your winning thumbnail")
                                    .font(Constants.Typography.bodyMedium)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .padding(Constants.Spacing.spacing20)
                        .background(
                            LinearGradient(
                                colors: [Constants.Colors.primaryRed, Constants.Colors.primaryRed.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(Constants.CornerRadius.large)
                    }
                    .padding(.horizontal)

                    // Stats Cards
                    if let user = authViewModel.currentUser {
                        StatsCardsView(user: user)
                            .padding(.horizontal)
                    }

                    // Recent Analyses
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing16) {
                        HStack {
                            Text("Recent Analyses")
                                .font(Constants.Typography.headlineMedium)
                            Spacer()
                            Button("See All") {
                                // TODO: Switch to history tab
                            }
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.primaryRed)
                        }
                        .padding(.horizontal)

                        if historyViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if historyViewModel.analyses.isEmpty {
                            EmptyStateView(
                                icon: "photo.stack",
                                title: "No analyses yet",
                                message: "Create your first thumbnail analysis to get started"
                            )
                            .padding()
                        } else {
                            ForEach(historyViewModel.analyses.prefix(3)) { analysis in
                                RecentAnalysisRow(analysis: analysis)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, Constants.Spacing.spacing24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Show notifications
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(Constants.Colors.textPrimary)
                    }
                }
            }
            .task {
                await historyViewModel.loadAnalyses(page: 1)
            }
        }
    }
}

// MARK: - Stats Cards View
struct StatsCardsView: View {
    let user: User

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing12) {
            StatCard(
                icon: "chart.bar.fill",
                value: "\(user.analysesThisMonth)",
                label: "This Month",
                color: Constants.Colors.primaryRed
            )

            StatCard(
                icon: "star.fill",
                value: "85",
                label: "Avg Score",
                color: Constants.Colors.warningOrange
            )

            StatCard(
                icon: "checkmark.circle.fill",
                value: "89%",
                label: "Accuracy",
                color: Constants.Colors.successGreen
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            Text(value)
                .font(Constants.Typography.headlineSmall)
                .fontWeight(.bold)

            Text(label)
                .font(Constants.Typography.captionLarge)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.spacing16)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
}

// MARK: - Recent Analysis Row
struct RecentAnalysisRow: View {
    let analysis: Analysis

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing12) {
            // Thumbnail Grid Preview
            HStack(spacing: 4) {
                ForEach(analysis.thumbnails.prefix(3)) { thumbnail in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(analysis.displayTitle)
                    .font(Constants.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack {
                    if let winner = analysis.winner {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(Constants.Colors.warningOrange)
                            Text("Score: \(winner.overallScore ?? 0)")
                        }
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(Constants.Colors.textSecondary)
                    }

                    Text("•")
                        .foregroundColor(Constants.Colors.textSecondary)

                    Text(analysis.formattedDate)
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(Constants.Spacing.spacing16)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text(title)
                .font(Constants.Typography.headlineSmall)
                .fontWeight(.semibold)

            Text(message)
                .font(Constants.Typography.bodyMedium)
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Constants.Spacing.spacing32)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
