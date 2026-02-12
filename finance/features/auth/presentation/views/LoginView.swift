//
//  LoginView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var rememberMe: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // White card container
                        VStack(spacing: 24) {
                            // Title
                            Text("Welcome to Finance Assistant")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
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
                                    .foregroundColor(.secondary)
                                
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

                            // Remember me and Forgot password
                            HStack {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                            .foregroundColor(rememberMe ? .appPrimary : .gray)
                                        Text("Remember me")
                                            .font(.system(size: 14))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text("Forgot password?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.appPrimary)
                                }
                            }
                            
                            // Error message display
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.appError)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Login button
                            Button(action: {
                                handleLogin()
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text("Login")
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
                            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((authManager.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                            
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
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 30)
                        .background(Color.appCardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        
                        // Sign up link
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)

                            NavigationLink(destination: RegisterView()) {
                                Text("Sign Up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appPrimary)
                            }
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 40)
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
                // Clear any errors when view appears
                authManager.clearError()
            }
        }
    }
    
    private func handleLogin() {
        // Clear any previous errors
        authManager.clearError()
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        // Sign in with Firebase
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
}

