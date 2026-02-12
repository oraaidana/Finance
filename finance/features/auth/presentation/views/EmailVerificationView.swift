//
//  EmailVerificationView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var isVerified = false
    @State private var isChecking = false
    @State private var showResendSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // White card container
                    VStack(spacing: 24) {
                        // Icon
                        Image(systemName: isVerified ? "checkmark.circle.fill" : "envelope.fill")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(isVerified ? .appSuccess : .appPrimary)
                            .padding(.top, 40)
                        
                        // Title
                        Text(isVerified ? "Email Verified!" : "Verify Your Email")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        // Description
                        if isVerified {
                            Text("Your email has been successfully verified. You can now access all features of the app.")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 16) {
                                Text("We've sent a verification email to:")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                
                                if let user = authManager.currentUser {
                                    Text(user.email)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Please check your inbox and click the verification link to verify your email address.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Error message
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.appError)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Success message for resend
                        if showResendSuccess {
                            Text("Verification email sent!")
                                .font(.system(size: 14))
                                .foregroundColor(.appSuccess)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        if !isVerified {
                            // Check Verification button
                            Button(action: {
                                checkVerification()
                            }) {
                                HStack {
                                    if isChecking {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text("Check Verification")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appPrimary)
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                            .disabled(isChecking || authManager.isLoading)
                            .opacity((isChecking || authManager.isLoading) ? 0.6 : 1.0)

                            // Resend Email button
                            Button(action: {
                                resendVerification()
                            }) {
                                Text("Resend Verification Email")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.appPrimary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .disabled(authManager.isLoading)
                            .opacity(authManager.isLoading ? 0.6 : 1.0)
                        } else {
                            // Continue button when verified
                            Button(action: {
                                // Navigate to main app (RootView will handle this)
                            }) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appPrimary)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.appCardBackground)
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
                    .foregroundColor(.appPrimary)
            }
        }
        .onAppear {
            authManager.clearError()
            // Check initial verification status
            if let user = authManager.currentUser {
                isVerified = user.isEmailVerified
            }
        }
    }
    
    private func checkVerification() {
        isChecking = true
        authManager.clearError()
        
        Task {
            let verified = await authManager.checkEmailVerification()
            
            await MainActor.run {
                isVerified = verified
                isChecking = false
            }
        }
    }
    
    private func resendVerification() {
        authManager.clearError()
        showResendSuccess = false
        
        Task {
            await authManager.sendEmailVerification()
            
            await MainActor.run {
                if authManager.errorMessage == nil {
                    showResendSuccess = true
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showResendSuccess = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EmailVerificationView()
    }
}

