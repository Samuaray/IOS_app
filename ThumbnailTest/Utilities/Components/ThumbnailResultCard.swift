//
//  ThumbnailResultCard.swift
//  ThumbnailTest
//
//  Card component for displaying thumbnail results
//

import SwiftUI

struct ThumbnailResultCard: View {
    let thumbnail: Thumbnail
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Constants.Spacing.spacing12) {
                // Thumbnail image with winner badge
                ZStack(alignment: .topLeading) {
                    // Placeholder image (in real app, load from URL)
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                .stroke(
                                    thumbnail.isWinner ? Constants.Colors.warningOrange : Color.clear,
                                    lineWidth: thumbnail.isWinner ? 3 : 0
                                )
                        )

                    // Winner badge
                    if thumbnail.isWinner {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 12))
                            Text("Winner")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Constants.Colors.warningOrange)
                        .cornerRadius(Constants.CornerRadius.small)
                        .padding(8)
                    }
                }

                // Score and CTR
                VStack(spacing: Constants.Spacing.spacing8) {
                    // Overall score
                    HStack {
                        Text("Score:")
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.textSecondary)

                        Spacer()

                        Text("\(thumbnail.overallScore ?? 0)/100")
                            .font(Constants.Typography.bodyLarge)
                            .fontWeight(.bold)
                            .foregroundColor(Color.scoreColor(for: thumbnail.overallScore ?? 0))
                    }

                    // Predicted CTR
                    HStack {
                        Text("Predicted CTR:")
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.textSecondary)

                        Spacer()

                        Text(thumbnail.displayCTR)
                            .font(Constants.Typography.bodyLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryRed)
                    }

                    // Mini progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: Color.scoreGradient(for: thumbnail.overallScore ?? 0),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * CGFloat(thumbnail.overallScore ?? 0) / 100.0,
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                }

                // View Details button
                Text("View Details")
                    .font(Constants.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.primaryRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Constants.Colors.primaryRed.opacity(0.1))
                    .cornerRadius(Constants.CornerRadius.small)
            }
            .padding(Constants.Spacing.spacing12)
            .background(Color.white)
            .cornerRadius(Constants.CornerRadius.medium)
            .shadow(color: Constants.Shadow.medium, radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        ThumbnailResultCard(thumbnail: .mock, onTap: {})
        ThumbnailResultCard(thumbnail: .mock2, onTap: {})
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
