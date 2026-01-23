//
//  ProfileView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared

    private var displayName: String {
        let name = authManager.currentUser?.name ?? ""
        return name.isEmpty ? "User" : name
    }

    private var avatarInitial: String {
        let name = authManager.currentUser?.name ?? ""
        if name.isEmpty {
            // Use first letter of email if no name
            let email = authManager.currentUser?.email ?? ""
            return String(email.prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    var body: some View {
        NavigationView {
            List {
                // Profile Header Section
                Section {
                    HStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color.appPrimary.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text(avatarInitial)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Account Settings Section
                Section {
                    NavigationLink(destination: EditProfileView()) {
                        SettingsRow(icon: "person.fill", title: "Edit Profile", color: .appPrimary)
                    }

                    NavigationLink(destination: SettingsView()) {
                        SettingsRow(icon: "paintbrush.fill", title: "Appearance", color: .purple)
                    }

                    NavigationLink(destination: PlaceholderView(title: "Notifications")) {
                        SettingsRow(icon: "bell.fill", title: "Notifications", color: .appWarning)
                    }
                } header: {
                    Text("Settings")
                }

                // Support Section
                Section {
                    NavigationLink(destination: PlaceholderView(title: "Privacy & Security")) {
                        SettingsRow(icon: "lock.fill", title: "Privacy & Security", color: .appSuccess)
                    }

                    NavigationLink(destination: PlaceholderView(title: "Help & Support")) {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .teal)
                    }

                    NavigationLink(destination: AboutView()) {
                        SettingsRow(icon: "info.circle.fill", title: "About", color: .appTextSecondary)
                    }
                } header: {
                    Text("Support")
                }

                // Logout Section
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.appError)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .cornerRadius(8)

            Text(title)
                .font(.body)
        }
    }
}

// MARK: - Placeholder View for unimplemented screens
struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(title) will be available in a future update.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle(title)
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Text("QarzhyAI is a finance tracker app with ML integration for smart expense tracking and financial recommendations.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } header: {
                Text("About QarzhyAI")
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    ProfileView()
}
