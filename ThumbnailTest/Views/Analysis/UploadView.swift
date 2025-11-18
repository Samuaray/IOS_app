//
//  UploadView.swift
//  ThumbnailTest
//
//  Image upload screen with photo library and camera
//

import SwiftUI

struct UploadView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var cameraImage: UIImage?
    @State private var showingLimitAlert = false

    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: Constants.Spacing.spacing24) {
            // Header
            VStack(spacing: Constants.Spacing.spacing8) {
                Text("Upload Thumbnails")
                    .font(Constants.Typography.headlineMedium)

                Text("Upload 2-4 thumbnail options")
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding(.top)

            // Image Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Constants.Spacing.spacing16) {
                    // Existing images
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                        ThumbnailCell(image: image) {
                            viewModel.removeImage(at: index)
                        }
                    }

                    // Add buttons
                    if viewModel.selectedImages.count < Constants.Analysis.maxThumbnails {
                        AddPhotoButton(
                            icon: "photo.on.rectangle",
                            title: "Photo Library"
                        ) {
                            showingImagePicker = true
                        }

                        if viewModel.selectedImages.count < Constants.Analysis.maxThumbnails - 1 {
                            AddPhotoButton(
                                icon: "camera",
                                title: "Take Photo"
                            ) {
                                showingCamera = true
                            }
                        }
                    }
                }
                .padding()
            }

            Spacer()

            // Info
            HStack(spacing: Constants.Spacing.spacing8) {
                Image(systemName: "info.circle")
                    .foregroundColor(Constants.Colors.textSecondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Minimum 2 thumbnails required")
                    Text("• Maximum \(Constants.Analysis.maxThumbnails) thumbnails")
                    Text("• Recommended: 1280x720 or higher")
                }
                .font(Constants.Typography.bodySmall)
                .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .padding(.horizontal)

            // Continue Button
            PrimaryButton(
                title: "Continue (\(viewModel.selectedImages.count)/\(Constants.Analysis.maxThumbnails))",
                action: onContinue,
                isEnabled: viewModel.canProceed
            )
            .padding()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                selectedImages: $viewModel.selectedImages,
                selectionLimit: Constants.Analysis.maxThumbnails - viewModel.selectedImages.count
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $cameraImage)
        }
        .onChange(of: cameraImage) { newImage in
            if let image = newImage {
                if viewModel.selectedImages.count < Constants.Analysis.maxThumbnails {
                    viewModel.addImage(image)
                    cameraImage = nil
                } else {
                    showingLimitAlert = true
                }
            }
        }
        .alert("Maximum Limit Reached", isPresented: $showingLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can only upload \(Constants.Analysis.maxThumbnails) thumbnails per analysis")
        }
    }
}

// MARK: - Thumbnail Cell
struct ThumbnailCell: View {
    let image: UIImage
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .cornerRadius(Constants.CornerRadius.medium)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 28, height: 28)
                    )
            }
            .padding(8)
        }
    }
}

// MARK: - Add Photo Button
struct AddPhotoButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.spacing12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(Constants.Colors.primaryRed)

                Text(title)
                    .font(Constants.Typography.bodySmall)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(Constants.Colors.primaryRed.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
    }
}

#Preview {
    UploadView(viewModel: AnalysisViewModel(), onContinue: {})
}
