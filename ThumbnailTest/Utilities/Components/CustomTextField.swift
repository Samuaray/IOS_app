//
//  CustomTextField.swift
//  ThumbnailTest
//
//  Reusable text field component
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.spacing8) {
            Text(title)
                .font(Constants.Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.textPrimary)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle()
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .textFieldStyle()
            }
        }
    }
}

// Custom text field style
extension View {
    func textFieldStyle() -> some View {
        self
            .font(Constants.Typography.bodyLarge)
            .padding(Constants.Spacing.spacing16)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            title: "Email",
            placeholder: "Enter your email",
            text: .constant("")
        )

        CustomTextField(
            title: "Password",
            placeholder: "Enter password",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
}
