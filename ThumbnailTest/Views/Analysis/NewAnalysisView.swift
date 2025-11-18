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
                            AnalysisResultsView(analysis: analysis)
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

#Preview {
    NewAnalysisView()
        .environmentObject(AuthViewModel())
}
