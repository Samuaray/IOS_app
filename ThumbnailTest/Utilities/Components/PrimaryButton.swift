//
//  PrimaryButton.swift
//  ThumbnailTest
//
//  Reusable primary button component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.spacing8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .font(Constants.Typography.bodyLarge)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(isEnabled && !isLoading ? Constants.Colors.primaryRed : Color.gray)
            .cornerRadius(Constants.CornerRadius.medium)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
    }
    .padding()
}
