//
//  AuthService.swift
//  ThumbnailTest
//
//  Authentication service with token management and Keychain storage
//

import Foundation
import Security

class AuthService {
    static let shared = AuthService()

    private let tokenKey = "com.thumbnailtest.authToken"
    private let refreshTokenKey = "com.thumbnailtest.refreshToken"

    private init() {}

    // MARK: - Request/Response Models
    struct SignupRequest: Encodable {
        let email: String
        let password: String
        let fullName: String

        enum CodingKeys: String, CodingKey {
            case email, password
            case fullName = "fullName"
        }
    }

    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    struct AppleSignInRequest: Encodable {
        let identityToken: String
        let authorizationCode: String
        let fullName: String?

        enum CodingKeys: String, CodingKey {
            case identityToken, authorizationCode, fullName
        }
    }

    struct GoogleSignInRequest: Encodable {
        let idToken: String
    }

    struct AuthResponse: Decodable {
        let user: User
        let token: String
        let refreshToken: String

        enum CodingKeys: String, CodingKey {
            case user, token, refreshToken
        }
    }

    // MARK: - Authentication Methods

    /// Sign up with email and password
    func signup(email: String, password: String, fullName: String) async throws -> User {
        let request = SignupRequest(email: email, password: password, fullName: fullName)
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: "/auth/signup",
            method: .post,
            body: request,
            requiresAuth: false
        )

        // Store tokens
        saveToken(response.token)
        saveRefreshToken(response.refreshToken)

        return response.user
    }

    /// Login with email and password
    func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: "/auth/login",
            method: .post,
            body: request,
            requiresAuth: false
        )

        // Store tokens
        saveToken(response.token)
        saveRefreshToken(response.refreshToken)

        return response.user
    }

    /// Sign in with Apple
    func signInWithApple(identityToken: String, authorizationCode: String, fullName: String?) async throws -> User {
        let request = AppleSignInRequest(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            fullName: fullName
        )
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: "/auth/apple",
            method: .post,
            body: request,
            requiresAuth: false
        )

        saveToken(response.token)
        saveRefreshToken(response.refreshToken)

        return response.user
    }

    /// Sign in with Google
    func signInWithGoogle(idToken: String) async throws -> User {
        let request = GoogleSignInRequest(idToken: idToken)
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: "/auth/google",
            method: .post,
            body: request,
            requiresAuth: false
        )

        saveToken(response.token)
        saveRefreshToken(response.refreshToken)

        return response.user
    }

    /// Logout
    func logout() {
        clearToken()
        clearRefreshToken()
    }

    // MARK: - Token Management (Keychain)

    func saveToken(_ token: String) {
        save(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return retrieve(forKey: tokenKey)
    }

    func clearToken() {
        delete(forKey: tokenKey)
    }

    private func saveRefreshToken(_ token: String) {
        save(token, forKey: refreshTokenKey)
    }

    private func getRefreshToken() -> String? {
        return retrieve(forKey: refreshTokenKey)
    }

    private func clearRefreshToken() {
        delete(forKey: refreshTokenKey)
    }

    func isAuthenticated() -> Bool {
        return getToken() != nil
    }

    // MARK: - Keychain Helpers

    private func save(_ value: String, forKey key: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item if present
        SecItemDelete(query as CFDictionary)

        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
