//
//  SettingsView.swift
//  ThumbnailTest
//
//  Settings and account management screen
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    if let user = authViewModel.currentUser {
                        ProfileHeaderView(user: user)
                    }
                }

                // Account Section
                Section("Account") {
                    if let user = authViewModel.currentUser {
                        NavigationLink(destination: SubscriptionManagementView()) {
                            HStack {
                                Image(systemName: user.isFreeTier ? "star" : "crown.fill")
                                    .foregroundColor(Constants.Colors.primaryRed)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Subscription")
                                        .foregroundColor(Constants.Colors.textPrimary)

                                    Text(user.subscriptionDisplayName)
                                        .font(Constants.Typography.bodySmall)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                }
                            }
                        }
                    }

                    NavigationLink(destination: ProfileEditView()) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .frame(width: 24)
                            Text("Edit Profile")
                        }
                    }
                }

                // Support Section
                Section("Support & Legal") {
                    Link(destination: URL(string: "https://thumbnailtest.app/help")!) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .frame(width: 24)
                            Text("Help Center")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                    }

                    Link(destination: URL(string: "https://thumbnailtest.app/privacy")!) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .frame(width: 24)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                    }

                    Link(destination: URL(string: "https://thumbnailtest.app/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .frame(width: 24)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Constants.Colors.primaryRed)
                            .frame(width: 24)
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }

                    Link(destination: URL(string: "https://thumbnailtest.app")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(Constants.Colors.primaryRed)
                                .frame(width: 24)
                            Text("Website")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                    }
                }

                // Danger Zone
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(Constants.Colors.errorRed)
                                .frame(width: 24)
                            Text("Log Out")
                                .foregroundColor(Constants.Colors.errorRed)
                        }
                    }

                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(Constants.Colors.errorRed)
                                .frame(width: 24)
                            Text("Delete Account")
                                .foregroundColor(Constants.Colors.errorRed)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("This action cannot be undone. All your analyses and data will be permanently deleted.")
            }
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func deleteAccount() async {
        do {
            try await UserService.shared.deleteAccount()
            authViewModel.logout()
        } catch {
            print("Failed to delete account: \(error)")
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    let user: User

    var body: some View {
        HStack(spacing: Constants.Spacing.spacing16) {
            // Profile Picture Placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Constants.Colors.primaryRed, Constants.Colors.primaryRed.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay {
                    Text(user.initials)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                if let fullName = user.fullName, !fullName.isEmpty {
                    Text(fullName)
                        .font(Constants.Typography.headlineSmall)
                        .fontWeight(.semibold)
                }

                Text(user.email)
                    .font(Constants.Typography.bodyMedium)
                    .foregroundColor(Constants.Colors.textSecondary)

                HStack(spacing: 4) {
                    if !user.isFreeTier {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(Constants.Colors.primaryRed)
                    }
                    Text(user.subscriptionDisplayName)
                        .font(Constants.Typography.bodySmall)
                        .foregroundColor(user.isFreeTier ? Constants.Colors.textSecondary : Constants.Colors.primaryRed)
                }
            }

            Spacer()
        }
        .padding(.vertical, Constants.Spacing.spacing8)
    }
}

// MARK: - Profile Edit View (Placeholder)
struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var channelName = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("Full Name", text: $fullName)
                TextField("YouTube Channel Name", text: $channelName)
            }

            Section("YouTube Details") {
                Picker("Content Niche", selection: .constant("")) {
                    Text("Select...").tag("")
                    Text("Tech & Gaming").tag("tech")
                    Text("Education").tag("education")
                    Text("Entertainment").tag("entertainment")
                    Text("Lifestyle").tag("lifestyle")
                    Text("Business").tag("business")
                }

                Picker("Subscriber Range", selection: .constant("")) {
                    Text("Select...").tag("")
                    Text("< 1K").tag("0-1k")
                    Text("1K - 10K").tag("1k-10k")
                    Text("10K - 100K").tag("10k-100k")
                    Text("100K - 1M").tag("100k-1m")
                    Text("1M+").tag("1m+")
                }

                Picker("Upload Frequency", selection: .constant("")) {
                    Text("Select...").tag("")
                    Text("Daily").tag("daily")
                    Text("Weekly").tag("weekly")
                    Text("Bi-weekly").tag("biweekly")
                    Text("Monthly").tag("monthly")
                }
            }

            Section {
                Button(action: {
                    Task {
                        await saveProfile()
                    }
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                        }
                        Text(isSaving ? "Saving..." : "Save Changes")
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = authViewModel.currentUser {
                fullName = user.fullName ?? ""
                channelName = user.channelName ?? ""
            }
        }
    }

    private func saveProfile() async {
        isSaving = true
        defer { isSaving = false }

        // TODO: Implement profile update API call
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate API call
            dismiss()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}

// MARK: - User Extension for Initials
extension User {
    var initials: String {
        if let fullName = fullName, !fullName.isEmpty {
            let components = fullName.components(separatedBy: " ")
            let initials = components.compactMap { $0.first }.prefix(2)
            return String(initials).uppercased()
        }
        // Fallback to email
        return String(email.prefix(2)).uppercased()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
