//
//  AnalysisHistoryRow.swift
//  ThumbnailTest
//
//  History list row component
//

import SwiftUI

struct AnalysisHistoryRow: View {
    let analysis: Analysis
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.spacing12) {
                // Thumbnail grid preview (mini)
                HStack(spacing: 4) {
                    ForEach(analysis.thumbnails.prefix(4)) { thumbnail in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        thumbnail.isWinner ? Constants.Colors.warningOrange : Color.clear,
                                        lineWidth: thumbnail.isWinner ? 2 : 0
                                    )
                            )
                    }
                }

                // Analysis info
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(analysis.displayTitle)
                        .font(Constants.Typography.bodyMedium)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(Constants.Colors.textPrimary)

                    // Metadata row
                    HStack(spacing: 8) {
                        // Winner badge
                        if let winner = analysis.winner {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.Colors.warningOrange)
                                Text("\(winner.overallScore ?? 0)")
                                    .font(Constants.Typography.bodySmall)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Constants.Colors.textSecondary)
                        }

                        Text("•")
                            .foregroundColor(Constants.Colors.textSecondary)
                            .font(Constants.Typography.bodySmall)

                        // Date
                        Text(analysis.formattedDate)
                            .font(Constants.Typography.bodySmall)
                            .foregroundColor(Constants.Colors.textSecondary)

                        // Status badge
                        if analysis.published {
                            Text("•")
                                .foregroundColor(Constants.Colors.textSecondary)
                                .font(Constants.Typography.bodySmall)

                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Published")
                                    .font(Constants.Typography.captionLarge)
                            }
                            .foregroundColor(Constants.Colors.successGreen)
                        }
                    }

                    // Category
                    if let category = analysis.category {
                        Text(category)
                            .font(Constants.Typography.captionLarge)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.primaryRed.opacity(0.1))
                            .cornerRadius(4)
                    }

                    // Actual CTR if published
                    if analysis.published, let actualCTR = analysis.actualCTR {
                        HStack(spacing: 4) {
                            Text("Actual CTR:")
                                .font(Constants.Typography.bodySmall)
                                .foregroundColor(Constants.Colors.textSecondary)
                            Text(String(format: "%.1f%%", actualCTR))
                                .font(Constants.Typography.bodySmall)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primaryRed)

                            // Accuracy indicator
                            if let accuracy = analysis.accuracy {
                                Text("•")
                                    .foregroundColor(Constants.Colors.textSecondary)
                                    .font(.system(size: 10))
                                Text(String(format: "%.0f%% accurate", accuracy))
                                    .font(Constants.Typography.bodySmall)
                                    .foregroundColor(Constants.Colors.successGreen)
                            }
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(Constants.Spacing.spacing12)
            .background(Color.white)
            .cornerRadius(Constants.CornerRadius.medium)
            .shadow(color: Constants.Shadow.light, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        AnalysisHistoryRow(analysis: .mock, onTap: {})
        AnalysisHistoryRow(analysis: .mockPublished, onTap: {})
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
