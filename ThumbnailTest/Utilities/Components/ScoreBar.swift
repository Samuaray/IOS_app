//
//  ScoreBar.swift
//  ThumbnailTest
//
//  Horizontal bar chart for score breakdown
//

import SwiftUI

struct ScoreBar: View {
    let title: String
    let score: Int
    let icon: String

    @State private var animatedWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
            // Title and score
            HStack {
                HStack(spacing: Constants.Spacing.spacing8) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color.scoreColor(for: score))
                        .frame(width: 20)

                    Text(title)
                        .font(Constants.Typography.bodyMedium)
                }

                Spacer()

                Text("\(score)")
                    .font(Constants.Typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.scoreColor(for: score))
                    .monospacedDigit()
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Filled portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: Color.scoreGradient(for: score),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedWidth, height: 8)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedWidth = CGFloat(score) / 100.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreBar(title: "Face Visibility", score: 95, icon: "face.smiling")
        ScoreBar(title: "Text Readability", score: 82, icon: "text.alignleft")
        ScoreBar(title: "Color Contrast", score: 65, icon: "paintpalette")
        ScoreBar(title: "Visual Clarity", score: 40, icon: "eye")
    }
    .padding()
}
