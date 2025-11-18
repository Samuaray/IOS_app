//
//  AnalysisService.swift
//  ThumbnailTest
//
//  Analysis creation and retrieval service
//

import Foundation

class AnalysisService {
    static let shared = AnalysisService()

    private init() {}

    // MARK: - Request Models
    struct CreateAnalysisRequest: Encodable {
        let videoTitle: String?
        let category: String?
        let notes: String?
        let thumbnails: [ThumbnailInput]

        struct ThumbnailInput: Encodable {
            let imageUrl: String
            let order: Int
        }
    }

    struct UpdateAnalysisRequest: Encodable {
        let published: Bool?
        let publishedAt: Date?
        let selectedThumbnailId: String?
        let youtubeVideoUrl: String?
        let actualCtr: Double?
        let actualViews: Int?

        enum CodingKeys: String, CodingKey {
            case published
            case publishedAt = "publishedAt"
            case selectedThumbnailId = "selectedThumbnailId"
            case youtubeVideoUrl = "youtubeVideoUrl"
            case actualCtr = "actualCtr"
            case actualViews = "actualViews"
        }
    }

    // MARK: - Response Models
    struct AnalysisListResponse: Decodable {
        let analyses: [Analysis]
        let pagination: Pagination

        struct Pagination: Decodable {
            let page: Int
            let limit: Int
            let total: Int
            let totalPages: Int
        }
    }

    // MARK: - Create Analysis
    func createAnalysis(
        videoTitle: String?,
        category: String?,
        notes: String?,
        imageUrls: [String]
    ) async throws -> Analysis {
        let thumbnails = imageUrls.enumerated().map { index, url in
            CreateAnalysisRequest.ThumbnailInput(imageUrl: url, order: index + 1)
        }

        let request = CreateAnalysisRequest(
            videoTitle: videoTitle,
            category: category,
            notes: notes,
            thumbnails: thumbnails
        )

        let response: Analysis = try await APIService.shared.request(
            endpoint: "/analysis/create",
            method: .post,
            body: request
        )

        return response
    }

    // MARK: - Get Analysis
    func getAnalysis(id: String) async throws -> Analysis {
        let response: Analysis = try await APIService.shared.request(
            endpoint: "/analysis/\(id)",
            method: .get
        )

        return response
    }

    // MARK: - Get Analysis List
    func getAnalysisList(
        page: Int = 1,
        limit: Int = 20,
        status: String? = nil,
        category: String? = nil,
        search: String? = nil
    ) async throws -> AnalysisListResponse {
        var endpoint = "/analysis/list?page=\(page)&limit=\(limit)"

        if let status = status {
            endpoint += "&status=\(status)"
        }
        if let category = category {
            endpoint += "&category=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category)"
        }
        if let search = search {
            endpoint += "&search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? search)"
        }

        let response: AnalysisListResponse = try await APIService.shared.request(
            endpoint: endpoint,
            method: .get
        )

        return response
    }

    // MARK: - Update Analysis
    func updateAnalysis(
        id: String,
        published: Bool? = nil,
        publishedAt: Date? = nil,
        selectedThumbnailId: String? = nil,
        youtubeVideoUrl: String? = nil,
        actualCtr: Double? = nil,
        actualViews: Int? = nil
    ) async throws -> Analysis {
        let request = UpdateAnalysisRequest(
            published: published,
            publishedAt: publishedAt,
            selectedThumbnailId: selectedThumbnailId,
            youtubeVideoUrl: youtubeVideoUrl,
            actualCtr: actualCtr,
            actualViews: actualViews
        )

        let response: Analysis = try await APIService.shared.request(
            endpoint: "/analysis/\(id)",
            method: .put,
            body: request
        )

        return response
    }

    // MARK: - Delete Analysis
    func deleteAnalysis(id: String) async throws {
        let _: EmptyResponse = try await APIService.shared.request(
            endpoint: "/analysis/\(id)",
            method: .delete
        )
    }

    private struct EmptyResponse: Decodable {}
}
