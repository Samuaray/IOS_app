//
//  View+Extensions.swift
//  ThumbnailTest
//
//  Common view modifiers and extensions
//

import SwiftUI

extension View {
    /// Apply card style with shadow
    func cardStyle(background: Color = .white) -> some View {
        self
            .background(background)
            .cornerRadius(Constants.CornerRadius.medium)
            .shadow(color: Constants.Shadow.medium, radius: 8, x: 0, y: 2)
    }

    /// Apply primary button style
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self
            .font(Constants.Typography.bodyLarge)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isEnabled ? Constants.Colors.primaryRed : Color.gray)
            .cornerRadius(Constants.CornerRadius.medium)
    }

    /// Apply secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .font(Constants.Typography.bodyLarge)
            .foregroundColor(Constants.Colors.primaryRed)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(Constants.Colors.primaryRed, lineWidth: 2)
            )
    }

    /// Apply standard padding
    func standardPadding() -> some View {
        self.padding(Constants.Spacing.spacing16)
    }

    /// Hide keyboard on tap
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Apply loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
    }

    /// Show error alert
    func errorAlert(error: Binding<Error?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Keyboard Dismissal
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}
