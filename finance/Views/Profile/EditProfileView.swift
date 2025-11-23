//
//  EditProfileView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared

    @State private var name: String = ""
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        Form {
            Section {
                // Avatar
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(name.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.blue)
                        )
                    Spacer()
                }
                .padding(.vertical, 16)
                .listRowBackground(Color.clear)
            }

            Section {
                TextField("Display Name", text: $name)
                    .textContentType(.name)
                    .autocapitalization(.words)

                HStack {
                    Text("Email")
                    Spacer()
                    Text(authManager.currentUser?.email ?? "")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Profile Information")
            } footer: {
                Text("Your email cannot be changed.")
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isSaving || name.isEmpty)
            }
        }
        .onAppear {
            name = authManager.currentUser?.name ?? ""
        }
        .alert("Profile Update", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertMessage.contains("success") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func saveProfile() {
        isSaving = true

        // TODO: Implement profile update via Firebase
        // For now, simulate a save
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            alertMessage = "Profile updated successfully!"
            showAlert = true
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView()
    }
}
