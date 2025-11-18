//
//  ImageService.swift
//  ThumbnailTest
//
//  Image upload and processing service
//

import UIKit
import Foundation

class ImageService {
    static let shared = ImageService()

    private init() {}

    // MARK: - Models
    struct PresignedURLRequest: Encodable {
        let fileName: String
        let fileType: String
        let fileSize: Int
    }

    struct PresignedURLResponse: Decodable {
        let uploadUrl: String
        let imageUrl: String
        let imageKey: String
        let expiresIn: Int

        enum CodingKeys: String, CodingKey {
            case uploadUrl = "uploadUrl"
            case imageUrl = "imageUrl"
            case imageKey = "imageKey"
            case expiresIn = "expiresIn"
        }
    }

    // MARK: - Image Validation
    func validateImage(_ image: UIImage) throws {
        // Check file size
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageError.compressionFailed
        }

        if imageData.count > Constants.Analysis.maxFileSize {
            throw ImageError.fileTooLarge
        }

        // Check dimensions
        let size = image.size
        if size.width < CGFloat(Constants.Analysis.minRecommendedWidth) ||
           size.height < CGFloat(Constants.Analysis.minRecommendedHeight) {
            // Just a warning, not blocking
            print("⚠️ Image resolution is below recommended: \(size.width)x\(size.height)")
        }
    }

    // MARK: - Image Compression
    func compressImage(_ image: UIImage, maxSizeBytes: Int = Constants.Analysis.maxFileSize) -> Data? {
        var compression: CGFloat = 0.9
        var imageData = image.jpegData(compressionQuality: compression)

        // Reduce compression until under size limit
        while let data = imageData, data.count > maxSizeBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    // MARK: - Get Presigned URL
    func getPresignedURL(for image: UIImage, fileName: String) async throws -> PresignedURLResponse {
        // Validate and compress image
        try validateImage(image)

        guard let imageData = compressImage(image) else {
            throw ImageError.compressionFailed
        }

        let request = PresignedURLRequest(
            fileName: fileName,
            fileType: "image/jpeg",
            fileSize: imageData.count
        )

        let response: PresignedURLResponse = try await APIService.shared.request(
            endpoint: "/upload/presigned-url",
            method: .post,
            body: request
        )

        return response
    }

    // MARK: - Upload to S3
    func uploadToS3(imageData: Data, presignedURL: String) async throws {
        guard let url = URL(string: presignedURL) else {
            throw ImageError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageError.uploadFailed
        }
    }

    // MARK: - Full Upload Flow
    func uploadImage(_ image: UIImage) async throws -> String {
        // 1. Get presigned URL from backend
        let fileName = "\(UUID().uuidString).jpg"
        let presignedResponse = try await getPresignedURL(for: image, fileName: fileName)

        // 2. Compress image
        guard let imageData = compressImage(image) else {
            throw ImageError.compressionFailed
        }

        // 3. Upload to S3
        try await uploadToS3(imageData: imageData, presignedURL: presignedResponse.uploadUrl)

        // 4. Return the final image URL
        return presignedResponse.imageUrl
    }

    // MARK: - Image Errors
    enum ImageError: LocalizedError {
        case compressionFailed
        case fileTooLarge
        case invalidURL
        case uploadFailed
        case invalidFormat

        var errorDescription: String? {
            switch self {
            case .compressionFailed:
                return "Failed to compress image"
            case .fileTooLarge:
                return "Image file is too large. Maximum size is 10MB."
            case .invalidURL:
                return "Invalid upload URL"
            case .uploadFailed:
                return "Failed to upload image"
            case .invalidFormat:
                return "Invalid image format. Use JPG, PNG, or HEIC."
            }
        }
    }
}
