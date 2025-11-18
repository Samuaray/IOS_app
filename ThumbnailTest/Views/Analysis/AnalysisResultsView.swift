//
//  AnalysisResultsView.swift
//  ThumbnailTest
//
//  Full results view with thumbnail comparison
//

import SwiftUI

struct AnalysisResultsView: View {
    let analysis: Analysis
    @Environment(\.dismiss) var dismiss
    @State private var selectedThumbnail: Thumbnail?

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.spacing24) {
                // Winner announcement
                if let winner = analysis.winner {
                    VStack(spacing: Constants.Spacing.spacing12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Constants.Colors.warningOrange)

                        Text("Thumbnail #\(winner.orderIndex) is your winner!")
                            .font(Constants.Typography.headlineSmall)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        HStack(spacing: Constants.Spacing.spacing16) {
                            VStack {
                                Text("\(winner.overallScore ?? 0)")
                                    .font(Constants.Typography.headlineMedium)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.scoreColor(for: winner.overallScore ?? 0))
                                Text("Score")
                                    .font(Constants.Typography.bodySmall)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }

                            Divider()
                                .frame(height: 40)

                            VStack {
                                Text(winner.displayCTR)
                                    .font(Constants.Typography.headlineMedium)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.primaryRed)
                                Text("Predicted CTR")
                                    .font(Constants.Typography.bodySmall)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                        }
                    }
                    .padding(Constants.Spacing.spacing20)
                    .frame(maxWidth: .infinity)
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.CornerRadius.large)
                }

                // Analysis info
                if let title = analysis.videoTitle {
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        Text("Analysis Details")
                            .font(Constants.Typography.headlineSmall)
                            .fontWeight(.semibold)

                        HStack {
                            Image(systemName: "play.rectangle")
                                .foregroundColor(Constants.Colors.textSecondary)
                            Text(title)
                                .font(Constants.Typography.bodyMedium)
                        }

                        if let category = analysis.category {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Text(category)
                                    .font(Constants.Typography.bodyMedium)
                            }
                        }

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Constants.Colors.textSecondary)
                            Text(analysis.formattedDate)
                                .font(Constants.Typography.bodyMedium)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.CornerRadius.medium)
                }

                // Thumbnails grid
                VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                    Text("Compare All Thumbnails")
                        .font(Constants.Typography.headlineSmall)
                        .fontWeight(.semibold)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Constants.Spacing.spacing16) {
                        ForEach(analysis.thumbnails.sorted(by: { ($0.overallScore ?? 0) > ($1.overallScore ?? 0) })) { thumbnail in
                            ThumbnailResultCard(thumbnail: thumbnail) {
                                selectedThumbnail = thumbnail
                            }
                        }
                    }
                }

                // Quick insights
                QuickInsightsView(analysis: analysis)

                // Action buttons
                VStack(spacing: Constants.Spacing.spacing12) {
                    PrimaryButton(title: "Save Analysis", action: {
                        // Already saved, just dismiss
                        dismiss()
                    })

                    Button(action: {
                        // TODO: Share functionality
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Results")
                        }
                        .font(Constants.Typography.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.primaryRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.primaryRed.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.medium)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(item: $selectedThumbnail) { thumbnail in
            NavigationStack {
                ThumbnailDetailView(thumbnail: thumbnail, analysis: analysis)
            }
        }
    }
}

// MARK: - Quick Insights
struct QuickInsightsView: View {
    let analysis: Analysis

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Constants.Colors.warningOrange)
                Text("Quick Insights")
                    .font(Constants.Typography.headlineSmall)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                if hasFaceDetected {
                    InsightRow(
                        icon: "face.smiling",
                        text: "Thumbnails with faces scored higher",
                        color: Constants.Colors.successGreen
                    )
                }

                if hasTextDetected {
                    InsightRow(
                        icon: "text.alignleft",
                        text: "Text was detected in your thumbnails",
                        color: Constants.Colors.primaryRed
                    )
                }

                InsightRow(
                    icon: "chart.bar.fill",
                    text: "Average score: \(analysis.averageScore)/100",
                    color: Color.scoreColor(for: analysis.averageScore)
                )

                if let winner = analysis.winner,
                   let predictedCTR = winner.predictedCTR {
                    InsightRow(
                        icon: "arrow.up.right",
                        text: String(format: "Expected %.1f%% more clicks with winner", predictedCTR - averageCTR),
                        color: Constants.Colors.successGreen
                    )
                }
            }
        }
        .padding()
        .background(Constants.Colors.warningOrange.opacity(0.1))
        .cornerRadius(Constants.CornerRadius.medium)
    }

    private var hasFaceDetected: Bool {
        analysis.thumbnails.contains(where: { $0.faceDetected == true })
    }

    private var hasTextDetected: Bool {
        analysis.thumbnails.contains(where: { $0.textDetected != nil && !($0.textDetected?.isEmpty ?? true) })
    }

    private var averageCTR: Double {
        let ctrs = analysis.thumbnails.compactMap { $0.predictedCTR }
        guard !ctrs.isEmpty else { return 0 }
        return ctrs.reduce(0, +) / Double(ctrs.count)
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(Constants.Typography.bodyMedium)
        }
    }
}

#Preview {
    NavigationStack {
        AnalysisResultsView(analysis: .mock)
    }
}
