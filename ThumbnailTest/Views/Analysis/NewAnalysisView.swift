//
//  NewAnalysisView.swift
//  ThumbnailTest
//
//  Main container for new analysis workflow
//

import SwiftUI

struct NewAnalysisView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AnalysisViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var currentStep: AnalysisStep = .upload
    @State private var showingPaywall = false

    enum AnalysisStep {
        case upload
        case details
        case loading
        case results
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                Group {
                    switch currentStep {
                    case .upload:
                        UploadView(viewModel: viewModel) {
                            // Continue to details
                            currentStep = .details
                        }

                    case .details:
                        DetailsView(
                            viewModel: viewModel,
                            onSkip: {
                                startAnalysis()
                            },
                            onAnalyze: {
                                startAnalysis()
                            }
                        )

                    case .loading:
                        LoadingView(viewModel: viewModel)

                    case .results:
                        if let analysis = viewModel.currentAnalysis {
                            ResultsView(analysis: analysis)
                        } else {
                            Text("No results available")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep == .upload {
                        Button("Cancel") {
                            dismiss()
                        }
                    } else if currentStep == .details {
                        Button(action: {
                            currentStep = .upload
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    if currentStep != .loading && currentStep != .results {
                        ProgressIndicator(
                            currentStep: currentStep == .upload ? 1 : 2,
                            totalSteps: 2
                        )
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
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
    }

    private func startAnalysis() {
        // Check if user has reached limit
        if let user = authViewModel.currentUser, user.hasReachedLimit {
            showingPaywall = true
            return
        }

        currentStep = .loading

        Task {
            await viewModel.uploadAndAnalyze()

            if viewModel.currentAnalysis != nil {
                currentStep = .results

                // Reload user to update analysis count
                await authViewModel.loadCurrentUser()
            } else if viewModel.errorMessage != nil {
                // Error occurred, go back to details
                currentStep = .details
            }
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Constants.Colors.primaryRed : Color.gray.opacity(0.3))
                    .frame(width: 30, height: 4)
            }
        }
    }
}

// MARK: - Placeholder Views (to be implemented)
struct ResultsView: View {
    let analysis: Analysis

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.spacing20) {
                // Winner badge
                VStack(spacing: Constants.Spacing.spacing8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Constants.Colors.warningOrange)

                    if let winner = analysis.winner {
                        Text("Thumbnail #\(winner.orderIndex) is your winner!")
                            .font(Constants.Typography.headlineSmall)
                            .fontWeight(.semibold)

                        Text("Score: \(winner.overallScore ?? 0)/100")
                            .font(Constants.Typography.bodyLarge)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                }
                .padding()

                // Placeholder for thumbnail grid
                Text("Results view - Full implementation in Phase 3")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // Dismiss
                }
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.spacing24) {
                Spacer()

                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Constants.Colors.primaryRed)

                Text("Upgrade to Creator")
                    .font(Constants.Typography.headlineLarge)

                Text("You've used all 3 free analyses this month. Upgrade for unlimited!")
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: Constants.Spacing.spacing12) {
                    FeatureRow(text: "Unlimited thumbnail analyses")
                    FeatureRow(text: "Detailed scoring breakdowns")
                    FeatureRow(text: "Performance tracking")
                    FeatureRow(text: "Export & share results")
                    FeatureRow(text: "Priority support")
                }
                .padding()

                Spacer()

                VStack(spacing: Constants.Spacing.spacing12) {
                    PrimaryButton(title: "Start 7-Day Free Trial", action: {
                        // TODO: Implement purchase
                    })

                    Button("Restore Purchases") {
                        // TODO: Implement restore
                    }
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding()
            }
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
}

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing8) {
            Image(systemName: "checkmark")
                .foregroundColor(Constants.Colors.successGreen)
            Text(text)
                .font(Constants.Typography.bodyMedium)
        }
    }
}

#Preview {
    NewAnalysisView()
        .environmentObject(AuthViewModel())
}
