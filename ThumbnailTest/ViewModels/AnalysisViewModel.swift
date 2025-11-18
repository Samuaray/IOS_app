//
//  AnalysisViewModel.swift
//  ThumbnailTest
//
//  Analysis creation and management
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class AnalysisViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var imageURLs: [String] = []

    @Published var videoTitle: String = ""
    @Published var selectedCategory: String?
    @Published var notes: String = ""

    @Published var currentAnalysis: Analysis?
    @Published var isLoading = false
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var errorMessage: String?

    // MARK: - Add Image
    func addImage(_ image: UIImage) {
        guard selectedImages.count < Constants.Analysis.maxThumbnails else {
            errorMessage = "Maximum \(Constants.Analysis.maxThumbnails) thumbnails allowed"
            return
        }

        selectedImages.append(image)
    }

    // MARK: - Remove Image
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        if index < imageURLs.count {
            imageURLs.remove(at: index)
        }
    }

    // MARK: - Reorder Images
    func moveImage(from source: IndexSet, to destination: Int) {
        selectedImages.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Validation
    var canProceed: Bool {
        return selectedImages.count >= Constants.Analysis.minThumbnails
    }

    var canAnalyze: Bool {
        return imageURLs.count >= Constants.Analysis.minThumbnails
    }

    // MARK: - Upload Images
    func uploadImages() async {
        guard !selectedImages.isEmpty else { return }

        isUploading = true
        uploadProgress = 0.0
        errorMessage = nil
        imageURLs = []

        let totalImages = selectedImages.count

        for (index, image) in selectedImages.enumerated() {
            do {
                let imageUrl = try await ImageService.shared.uploadImage(image)
                imageURLs.append(imageUrl)

                // Update progress
                uploadProgress = Double(index + 1) / Double(totalImages)
            } catch {
                errorMessage = "Failed to upload image \(index + 1): \(error.localizedDescription)"
                isUploading = false
                return
            }
        }

        isUploading = false
        uploadProgress = 1.0
    }

    // MARK: - Create Analysis
    func createAnalysis() async {
        guard canAnalyze else {
            errorMessage = "Please upload at least \(Constants.Analysis.minThumbnails) images"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let analysis = try await AnalysisService.shared.createAnalysis(
                videoTitle: videoTitle.isEmpty ? nil : videoTitle,
                category: selectedCategory,
                notes: notes.isEmpty ? nil : notes,
                imageUrls: imageURLs
            )

            currentAnalysis = analysis
        } catch let error as APIService.APIError {
            if case .analysisLimit = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Analysis failed: \(error.localizedDescription)"
            }
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Full Flow (Upload + Analyze)
    func uploadAndAnalyze() async {
        // 1. Upload images
        await uploadImages()

        guard errorMessage == nil else { return }

        // 2. Create analysis
        await createAnalysis()
    }

    // MARK: - Reset
    func reset() {
        selectedImages = []
        imageURLs = []
        videoTitle = ""
        selectedCategory = nil
        notes = ""
        currentAnalysis = nil
        isLoading = false
        isUploading = false
        uploadProgress = 0.0
        errorMessage = nil
    }

    // MARK: - Update Analysis
    func updateAnalysis(
        id: String,
        selectedThumbnailId: String? = nil,
        youtubeVideoUrl: String? = nil,
        actualCtr: Double? = nil,
        actualViews: Int? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let updated = try await AnalysisService.shared.updateAnalysis(
                id: id,
                published: true,
                publishedAt: Date(),
                selectedThumbnailId: selectedThumbnailId,
                youtubeVideoUrl: youtubeVideoUrl,
                actualCtr: actualCtr,
                actualViews: actualViews
            )

            currentAnalysis = updated
        } catch {
            errorMessage = "Failed to update analysis: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
