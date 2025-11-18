//
//  AuthViewModel.swift
//  ThumbnailTest
//
//  Authentication state management
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        checkAuthStatus()
    }

    // MARK: - Check Auth Status
    func checkAuthStatus() {
        isAuthenticated = AuthService.shared.isAuthenticated()

        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Load Current User
    func loadCurrentUser() async {
        do {
            currentUser = try await UserService.shared.getProfile()
        } catch {
            print("Failed to load user profile: \(error)")
            // Don't logout on profile load failure
        }
    }

    // MARK: - Sign Up
    func signup(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await AuthService.shared.signup(
                email: email,
                password: password,
                fullName: fullName
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await AuthService.shared.login(
                email: email,
                password: password
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign In with Apple
    func signInWithApple(identityToken: String, authorizationCode: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await AuthService.shared.signInWithApple(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                fullName: fullName
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign In with Google
    func signInWithGoogle(idToken: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await AuthService.shared.signInWithGoogle(idToken: idToken)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Logout
    func logout() {
        AuthService.shared.logout()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Validation
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    func validateFullName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
