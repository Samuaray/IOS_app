//
//  LoadingView.swift
//  ThumbnailTest
//
//  Loading screen during image upload and analysis
//

import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: AnalysisViewModel

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing32) {
            Spacer()

            // Animation
            ZStack {
                Circle()
                    .stroke(Constants.Colors.primaryRed.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: viewModel.isUploading ? viewModel.uploadProgress : 0.75)
                    .stroke(
                        Constants.Colors.primaryRed,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(viewModel.isUploading ? 0 : -90))
                    .animation(
                        viewModel.isUploading ? .linear : .linear(duration: 1).repeatForever(autoreverses: false),
                        value: viewModel.isUploading
                    )

                Image(systemName: "photo.stack")
                    .font(.system(size: 40))
                    .foregroundColor(Constants.Colors.primaryRed)
            }

            // Status text
            VStack(spacing: Constants.Spacing.spacing12) {
                Text(statusTitle)
                    .font(Constants.Typography.headlineSmall)
                    .fontWeight(.semibold)

                Text(statusMessage)
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                if viewModel.isUploading {
                    Text("\(Int(viewModel.uploadProgress * 100))%")
                        .font(Constants.Typography.headlineSmall)
                        .foregroundColor(Constants.Colors.primaryRed)
                        .monospacedDigit()
                }
            }

            Spacer()

            // Fun facts
            VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                HStack(spacing: Constants.Spacing.spacing8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Constants.Colors.warningOrange)
                    Text("Did you know?")
                        .font(Constants.Typography.bodyMedium)
                        .fontWeight(.semibold)
                }

                Text("Thumbnails with faces get 38% more clicks than those without!")
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .padding()
        }
    }

    private var statusTitle: String {
        if viewModel.isUploading {
            return "Uploading images..."
        } else if viewModel.isLoading {
            return "Analyzing your thumbnails..."
        } else {
            return "Processing..."
        }
    }

    private var statusMessage: String {
        if viewModel.isUploading {
            return "Securely uploading your images to the cloud"
        } else if viewModel.isLoading {
            return "Our AI is evaluating each thumbnail for maximum impact"
        } else {
            return "Please wait while we process your request"
        }
    }
}

#Preview {
    LoadingView(viewModel: {
        let vm = AnalysisViewModel()
        vm.isUploading = true
        vm.uploadProgress = 0.6
        return vm
    }())
}
