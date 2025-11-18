//
//  APIService.swift
//  ThumbnailTest
//
//  Core networking service for all API calls
//

import Foundation

class APIService {
    static let shared = APIService()

    private let baseURL = Constants.API.currentURL
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.timeout
        configuration.timeoutIntervalForResource = Constants.API.timeout
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - HTTP Methods
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    // MARK: - API Errors
    enum APIError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case serverError(String)
        case unauthorized
        case analysisLimit
        case notFound
        case validationError(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError:
                return "Failed to decode response"
            case .serverError(let message):
                return message
            case .unauthorized:
                return "Unauthorized. Please log in again."
            case .analysisLimit:
                return "You've reached your monthly limit. Upgrade to Creator for unlimited analyses."
            case .notFound:
                return "Resource not found"
            case .validationError(let message):
                return message
            }
        }
    }

    // MARK: - Response Models
    struct APIResponse<T: Decodable>: Decodable {
        let success: Bool
        let data: T?
        let error: ErrorDetails?
    }

    struct ErrorDetails: Decodable {
        let code: String
        let message: String
        let details: [String: String]?
    }

    // MARK: - Request Builder
    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if required
        if requiresAuth, let token = AuthService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            requiresAuth: requiresAuth
        )

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: -1))
            }

            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)

                if apiResponse.success, let data = apiResponse.data {
                    return data
                } else if let error = apiResponse.error {
                    throw parseError(error)
                } else {
                    throw APIError.serverError("Unknown error")
                }

            case 401:
                // Unauthorized - clear token
                AuthService.shared.clearToken()
                throw APIError.unauthorized

            case 403:
                // Forbidden - might be analysis limit
                let decoder = JSONDecoder()
                if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: data),
                   let error = apiResponse.error,
                   error.code == "ANALYSIS_LIMIT" {
                    throw APIError.analysisLimit
                }
                throw APIError.serverError("Access forbidden")

            case 404:
                throw APIError.notFound

            case 400:
                // Validation error
                let decoder = JSONDecoder()
                if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: data),
                   let error = apiResponse.error {
                    throw parseError(error)
                }
                throw APIError.validationError("Invalid request")

            default:
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            }

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Helper Methods
    private func parseError(_ error: ErrorDetails) -> APIError {
        switch error.code {
        case "AUTH_REQUIRED", "UNAUTHORIZED":
            return .unauthorized
        case "ANALYSIS_LIMIT":
            return .analysisLimit
        case "NOT_FOUND":
            return .notFound
        case "VALIDATION_ERROR":
            return .validationError(error.message)
        default:
            return .serverError(error.message)
        }
    }
}
