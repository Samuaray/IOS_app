//
//  LoginView.swift
//  ThumbnailTest
//
//  Login screen with email/password and social auth
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showingSignup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Spacing.spacing32) {
                    // Logo and Title
                    VStack(spacing: Constants.Spacing.spacing16) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(Constants.Colors.primaryRed)

                        Text("ThumbnailTest")
                            .font(Constants.Typography.headlineLarge)

                        Text("AI-powered thumbnail testing for YouTube creators")
                            .font(Constants.Typography.bodyMedium)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)

                    // Email/Password Fields
                    VStack(spacing: Constants.Spacing.spacing16) {
                        CustomTextField(
                            title: "Email",
                            placeholder: "your@email.com",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        CustomTextField(
                            title: "Password",
                            placeholder: "Enter password",
                            text: $password,
                            isSecure: true
                        )

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // TODO: Implement forgot password
                            }
                            .font(Constants.Typography.bodySmall)
                            .foregroundColor(Constants.Colors.primaryRed)
                        }
                    }

                    // Login Button
                    PrimaryButton(
                        title: "Log In",
                        action: {
                            Task {
                                await authViewModel.login(email: email, password: password)
                            }
                        },
                        isEnabled: !email.isEmpty && !password.isEmpty,
                        isLoading: authViewModel.isLoading
                    )

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .font(Constants.Typography.bodySmall)
                            .foregroundColor(Constants.Colors.textSecondary)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }

                    // Social Login Buttons
                    VStack(spacing: Constants.Spacing.spacing12) {
                        // Apple Sign In
                        Button(action: {
                            // TODO: Implement Apple Sign In
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Continue with Apple")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(Constants.CornerRadius.medium)
                        }

                        // Google Sign In
                        Button(action: {
                            // TODO: Implement Google Sign In
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continue with Google")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(Constants.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(Constants.Colors.textSecondary)
                        Button("Sign Up") {
                            showingSignup = true
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.primaryRed)
                    }
                    .font(Constants.Typography.bodyMedium)
                    .padding(.top, Constants.Spacing.spacing16)
                }
                .padding(Constants.Spacing.spacing24)
            }
            .navigationDestination(isPresented: $showingSignup) {
                SignupView()
            }
        }
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
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
