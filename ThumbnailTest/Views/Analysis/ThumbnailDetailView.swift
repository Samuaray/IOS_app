//
//  ThumbnailDetailView.swift
//  ThumbnailTest
//
//  Detailed breakdown for individual thumbnail
//

import SwiftUI

struct ThumbnailDetailView: View {
    let thumbnail: Thumbnail
    let analysis: Analysis
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.spacing24) {
                // Thumbnail preview
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                                .stroke(
                                    thumbnail.isWinner ? Constants.Colors.warningOrange : Color.clear,
                                    lineWidth: thumbnail.isWinner ? 3 : 0
                                )
                        )

                    // Winner badge
                    if thumbnail.isWinner {
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill")
                            Text("Winner")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Constants.Colors.warningOrange)
                        .cornerRadius(Constants.CornerRadius.small)
                        .padding(12)
                    }
                }

                // Overall score
                VStack(spacing: Constants.Spacing.spacing16) {
                    Text("Overall Score")
                        .font(Constants.Typography.headlineSmall)
                        .fontWeight(.semibold)

                    CircularScoreView(
                        score: thumbnail.overallScore ?? 0,
                        size: 140
                    )

                    HStack(spacing: Constants.Spacing.spacing24) {
                        VStack(spacing: 4) {
                            Text("Predicted CTR")
                                .font(Constants.Typography.bodySmall)
                                .foregroundColor(Constants.Colors.textSecondary)
                            Text(thumbnail.displayCTR)
                                .font(Constants.Typography.headlineSmall)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.primaryRed)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack(spacing: 4) {
                            Text("Rank")
                                .font(Constants.Typography.bodySmall)
                                .foregroundColor(Constants.Colors.textSecondary)
                            Text("#\(thumbnail.orderIndex)")
                                .font(Constants.Typography.headlineSmall)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Constants.Colors.cardBackground)
                .cornerRadius(Constants.CornerRadius.large)

                // Score breakdown
                VStack(alignment: .leading, spacing: Constants.Spacing.spacing16) {
                    Text("Score Breakdown")
                        .font(Constants.Typography.headlineSmall)
                        .fontWeight(.semibold)

                    VStack(spacing: Constants.Spacing.spacing16) {
                        ForEach(thumbnail.scoreBreakdown) { item in
                            ScoreBar(
                                title: item.name,
                                score: item.score,
                                icon: item.icon
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(Constants.CornerRadius.medium)
                .shadow(color: Constants.Shadow.light, radius: 4, x: 0, y: 2)

                // Detected elements
                VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                    Text("Detected Elements")
                        .font(Constants.Typography.headlineSmall)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        HStack {
                            Image(systemName: thumbnail.faceDetected == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(thumbnail.faceDetected == true ? Constants.Colors.successGreen : Color.gray)
                            Text("Face Detected")
                                .font(Constants.Typography.bodyMedium)
                        }

                        if let text = thumbnail.textDetected, !text.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "text.bubble")
                                        .foregroundColor(Constants.Colors.primaryRed)
                                    Text("Text Detected:")
                                        .font(Constants.Typography.bodyMedium)
                                        .fontWeight(.medium)
                                }

                                Text("\"\(text)\"")
                                    .font(Constants.Typography.bodyMedium)
                                    .italic()
                                    .foregroundColor(Constants.Colors.textSecondary)
                                    .padding(.leading, 28)
                            }
                        } else {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.gray)
                                Text("No Text Detected")
                                    .font(Constants.Typography.bodyMedium)
                            }
                        }
                    }
                }
                .padding()
                .background(Constants.Colors.cardBackground)
                .cornerRadius(Constants.CornerRadius.medium)

                // Recommendations
                if let recommendations = thumbnail.recommendations, !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(Constants.Colors.warningOrange)
                            Text("Recommendations")
                                .font(Constants.Typography.headlineSmall)
                                .fontWeight(.semibold)
                        }

                        VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                            ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                                HStack(alignment: .top, spacing: Constants.Spacing.spacing12) {
                                    Text("\(index + 1).")
                                        .font(Constants.Typography.bodyMedium)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Constants.Colors.primaryRed)

                                    Text(recommendation)
                                        .font(Constants.Typography.bodyMedium)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Constants.Colors.warningOrange.opacity(0.1))
                    .cornerRadius(Constants.CornerRadius.medium)
                }

                // Actions
                VStack(spacing: Constants.Spacing.spacing12) {
                    if !thumbnail.isSelected {
                        PrimaryButton(
                            title: "Mark as Used",
                            action: {
                                // TODO: Update analysis
                            }
                        )
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.Colors.successGreen)
                            Text("This thumbnail was used")
                                .fontWeight(.semibold)
                        }
                        .font(Constants.Typography.bodyLarge)
                        .foregroundColor(Constants.Colors.successGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Constants.Colors.successGreen.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.medium)
                    }

                    Button(action: {
                        // TODO: Export functionality
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Details")
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
        .navigationTitle("Thumbnail #\(thumbnail.orderIndex)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThumbnailDetailView(thumbnail: .mock, analysis: .mock)
    }
}
