//
//  CircularScoreView.swift
//  ThumbnailTest
//
//  Circular progress indicator for scores
//

import SwiftUI

struct CircularScoreView: View {
    let score: Int
    let size: CGFloat
    var lineWidth: CGFloat = 12
    var showPercentage: Bool = true

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: Color.scoreGradient(for: score),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Score text
            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: size * 0.3, weight: .bold))
                    .foregroundColor(Color.scoreColor(for: score))

                if showPercentage {
                    Text("/100")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = CGFloat(score) / 100.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CircularScoreView(score: 87, size: 120)
        CircularScoreView(score: 65, size: 100)
        CircularScoreView(score: 45, size: 80)
    }
    .padding()
}
