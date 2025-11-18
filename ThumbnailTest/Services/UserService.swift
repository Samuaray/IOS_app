//
//  UserService.swift
//  ThumbnailTest
//
//  User profile and subscription management service
//

import Foundation

class UserService {
    static let shared = UserService()

    private init() {}

    // MARK: - Request Models
    struct UpdateProfileRequest: Encodable {
        let fullName: String?
        let channelName: String?
        let contentNiche: String?
        let subscriberRange: String?

        enum CodingKeys: String, CodingKey {
            case fullName, channelName, contentNiche, subscriberRange
        }
    }

    // MARK: - Get Profile
    func getProfile() async throws -> User {
        let response: User = try await APIService.shared.request(
            endpoint: "/user/profile",
            method: .get
        )

        return response
    }

    // MARK: - Update Profile
    func updateProfile(
        fullName: String? = nil,
        channelName: String? = nil,
        contentNiche: String? = nil,
        subscriberRange: String? = nil
    ) async throws -> User {
        let request = UpdateProfileRequest(
            fullName: fullName,
            channelName: channelName,
            contentNiche: contentNiche,
            subscriberRange: subscriberRange
        )

        let response: User = try await APIService.shared.request(
            endpoint: "/user/profile",
            method: .put,
            body: request
        )

        return response
    }

    // MARK: - Get Subscription Info
    func getSubscription() async throws -> SubscriptionInfo {
        let response: SubscriptionInfo = try await APIService.shared.request(
            endpoint: "/user/subscription",
            method: .get
        )

        return response
    }

    // MARK: - Delete Account
    func deleteAccount() async throws {
        struct EmptyResponse: Decodable {}

        let _: EmptyResponse = try await APIService.shared.request(
            endpoint: "/user/account",
            method: .delete
        )
    }
}
