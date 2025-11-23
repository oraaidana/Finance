//
//  ForgotPasswordView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email: String = ""
    @State private var isEmailSent = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // White card container
                    VStack(spacing: 24) {
                        // Icon
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.blue)
                            .padding(.top, 40)
                        
                        // Title
                        Text("Forgot Password?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        // Description
                        if !isEmailSent {
                            Text("Enter your email address and we'll send you a link to reset your password")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        } else {
                            Text("We've sent a password reset link to your email. Please check your inbox and follow the instructions.")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        if !isEmailSent {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            .padding(.top, 20)
                            
                            // Error message
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Send Reset Link button
                            Button(action: {
                                handlePasswordReset()
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text("Send Reset Link")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                            .disabled(authManager.isLoading || email.isEmpty)
                            .opacity((authManager.isLoading || email.isEmpty) ? 0.6 : 1.0)
                        } else {
                            // Success state
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .padding(.top, 20)
                            
                            // Back to Login button
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Back to Login")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("QarzhyAI")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.5))
            }
        }
        .onAppear {
            authManager.clearError()
        }
    }
    
    private func handlePasswordReset() {
        authManager.clearError()
        
        guard !email.isEmpty else {
            return
        }
        
        Task {
            await authManager.sendPasswordReset(email: email)
            
            // If successful, show success message
            if authManager.errorMessage == nil {
                await MainActor.run {
                    isEmailSent = true
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ForgotPasswordView()
    }
}

