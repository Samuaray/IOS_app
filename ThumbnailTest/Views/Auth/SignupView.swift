//
//  SignupView.swift
//  ThumbnailTest
//
//  Sign up screen with email/password
//

import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.spacing24) {
                // Header
                VStack(spacing: Constants.Spacing.spacing8) {
                    Text("Create Account")
                        .font(Constants.Typography.headlineLarge)

                    Text("Start testing your thumbnails today")
                        .font(Constants.Typography.bodyMedium)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(.top, 20)

                // Form Fields
                VStack(spacing: Constants.Spacing.spacing16) {
                    CustomTextField(
                        title: "Full Name",
                        placeholder: "John Doe",
                        text: $fullName,
                        autocapitalization: .words
                    )

                    CustomTextField(
                        title: "Email",
                        placeholder: "your@email.com",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )

                    CustomTextField(
                        title: "Password",
                        placeholder: "Minimum 8 characters",
                        text: $password,
                        isSecure: true
                    )

                    CustomTextField(
                        title: "Confirm Password",
                        placeholder: "Re-enter password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                }

                // Validation Messages
                VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
                    ValidationRow(
                        isValid: password.count >= 8,
                        text: "At least 8 characters"
                    )
                    ValidationRow(
                        isValid: !confirmPassword.isEmpty && password == confirmPassword,
                        text: "Passwords match"
                    )
                }
                .padding(.horizontal, Constants.Spacing.spacing4)

                // Sign Up Button
                PrimaryButton(
                    title: "Create Account",
                    action: {
                        Task {
                            await authViewModel.signup(
                                email: email,
                                password: password,
                                fullName: fullName
                            )
                        }
                    },
                    isEnabled: isFormValid,
                    isLoading: authViewModel.isLoading
                )

                // Terms
                Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                    .font(Constants.Typography.bodySmall)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(Constants.Colors.textSecondary)
                    Button("Log In") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.primaryRed)
                }
                .font(Constants.Typography.bodyMedium)
                .padding(.top, Constants.Spacing.spacing16)
            }
            .padding(Constants.Spacing.spacing24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            if let error = authViewModel.errorMessage {
                Text(error)
            }
        }
    }

    private var isFormValid: Bool {
        return !fullName.isEmpty &&
               authViewModel.validateEmail(email) &&
               authViewModel.validatePassword(password) &&
               password == confirmPassword
    }
}

// Validation Row Component
struct ValidationRow: View {
    let isValid: Bool
    let text: String

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? Constants.Colors.successGreen : Color.gray)
                .font(.system(size: 16))

            Text(text)
                .font(Constants.Typography.bodySmall)
                .foregroundColor(isValid ? Constants.Colors.successGreen : Constants.Colors.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AuthViewModel())
    }
}
