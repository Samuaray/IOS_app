//
//  DetailsView.swift
//  ThumbnailTest
//
//  Optional analysis details form
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    var onSkip: () -> Void
    var onAnalyze: () -> Void

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing24) {
            // Header
            VStack(spacing: Constants.Spacing.spacing8) {
                Text("Add Details (Optional)")
                    .font(Constants.Typography.headlineMedium)

                Text("Help us analyze better")
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding(.top)

            ScrollView {
                VStack(spacing: Constants.Spacing.spacing20) {
                    // Video Title
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        Text("Video Title (Optional)")
                            .font(Constants.Typography.bodyMedium)
                            .fontWeight(.medium)

                        TextField("How to Build iOS Apps in 2025", text: $viewModel.videoTitle)
                            .textFieldStyle()
                    }

                    // Category
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        Text("Category (Optional)")
                            .font(Constants.Typography.bodyMedium)
                            .fontWeight(.medium)

                        Menu {
                            Button("None") {
                                viewModel.selectedCategory = nil
                            }
                            ForEach(Constants.categories, id: \.self) { category in
                                Button(category) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedCategory ?? "Select category")
                                    .foregroundColor(viewModel.selectedCategory == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .font(Constants.Typography.bodyLarge)
                            .padding(Constants.Spacing.spacing16)
                            .background(Constants.Colors.cardBackground)
                            .cornerRadius(Constants.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                        Text("Notes (Optional)")
                            .font(Constants.Typography.bodyMedium)
                            .fontWeight(.medium)

                        TextEditor(text: $viewModel.notes)
                            .frame(height: 100)
                            .padding(Constants.Spacing.spacing12)
                            .background(Constants.Colors.cardBackground)
                            .cornerRadius(Constants.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // Info box
                    HStack(alignment: .top, spacing: Constants.Spacing.spacing12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Constants.Colors.warningOrange)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pro Tip")
                                .font(Constants.Typography.bodyMedium)
                                .fontWeight(.semibold)

                            Text("Adding context helps our AI provide more accurate analysis and tailored recommendations.")
                                .font(Constants.Typography.bodySmall)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                    }
                    .padding()
                    .background(Constants.Colors.warningOrange.opacity(0.1))
                    .cornerRadius(Constants.CornerRadius.medium)
                }
                .padding()
            }

            Spacer()

            // Buttons
            HStack(spacing: Constants.Spacing.spacing12) {
                Button(action: onSkip) {
                    Text("Skip")
                        .font(Constants.Typography.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }

                PrimaryButton(
                    title: "Analyze Now",
                    action: onAnalyze,
                    isEnabled: true
                )
            }
            .padding()
        }
    }
}

#Preview {
    DetailsView(
        viewModel: AnalysisViewModel(),
        onSkip: {},
        onAnalyze: {}
    )
}
