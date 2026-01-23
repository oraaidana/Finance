//
//  RegisterView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var agreeToTerms: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // White card container
                    VStack(spacing: 24) {
                        // Title
                        Text("Create an Account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                        
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appTextSecondary)

                            TextField("Enter your name", text: $name)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.appBackground)
                                .cornerRadius(10)
                        }

                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appTextSecondary)

                            TextField("Enter your email", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.appBackground)
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .background(Color.appBackground)
                            .cornerRadius(10)
                        }

                        // Terms of Service
                        Button(action: {
                            agreeToTerms.toggle()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(agreeToTerms ? .appPrimary : .gray)

                                HStack(spacing: 4) {
                                    Text("I agree to the")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)

                                    Text("Terms of Service")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.appPrimary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Error message display
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.appError)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Create Account button
                        Button(action: {
                            handleRegister()
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .disabled(!agreeToTerms || name.isEmpty || email.isEmpty || password.isEmpty || authManager.isLoading)
                        .opacity((!agreeToTerms || name.isEmpty || email.isEmpty || password.isEmpty || authManager.isLoading) ? 0.6 : 1.0)

                        // Social login section
                        VStack(spacing: 16) {
                            Text("Or Sign in with")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                            
                            HStack(spacing: 20) {
                                // Facebook
                                Button(action: {
                                    // Handle Facebook login
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.appSecondary)
                                            .frame(width: 50, height: 50)
                                        Text("f")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.appPrimary)
                                    }
                                }
                                .buttonStyle(.plain)

                                // Google
                                Button(action: {
                                    // Handle Google login
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.appSecondary)
                                            .frame(width: 50, height: 50)
                                        Text("G")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.appExpense)
                                    }
                                }
                                .buttonStyle(.plain)

                                // Apple
                                Button(action: {
                                    // Handle Apple login
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.appSecondary)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "applelogo")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.appTextPrimary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 20)

                        // Login link - moved inside the card
                        HStack {
                            Text("Already have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)

                            Button(action: {
                                dismiss()
                            }) {
                                Text("Login")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 30)
                    .background(Color.appCardBackground)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("QarzhyAI")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appPrimary)
            }
        }
        .onAppear {
            // Clear any errors when view appears
            authManager.clearError()
        }
    }
    
    private func handleRegister() {
        // Clear any previous errors
        authManager.clearError()
        
        // Validate input
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, agreeToTerms else {
            return
        }
        
        // Sign up with Firebase
        Task {
            await authManager.signUp(email: email, password: password, name: name)
            
            // After successful signup, if email is not verified,
            // RootView will automatically show email verification screen
        }
    }
}

#Preview {
    NavigationView {
        RegisterView()
    }
}

