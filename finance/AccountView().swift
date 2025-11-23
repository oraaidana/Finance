//
//  Account.swift
//  upload_statement
//
//  Created by Aidana Orazbay on 11/22/25.
//

import SwiftUI
import SwiftUI
import Combine
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var isSent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Forgot Password?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.top, 20)
                
                if isSent {
                    Text("Reset instructions sent to your email!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                }
                
                Button(action: resetPassword) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Send Reset Instructions")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!email.isEmpty && !isLoading ? Color.orange : Color.gray)
                    )
                }
                .disabled(email.isEmpty || isLoading)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                
                }
            }
        }
    }
    
    private func resetPassword() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isSent = true
        }
    }
}
struct RegisterView: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Join us today")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Full Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your full name", text: $viewModel.fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.words)
                    }
                    
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your email", text: $viewModel.registerEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        SecureField("Create a password", text: $viewModel.registerPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        SecureField("Confirm your password", text: $viewModel.confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Password Requirements
                    if !viewModel.registerPassword.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            RequirementRow(
                                text: "At least 6 characters",
                                isMet: viewModel.registerPassword.count >= 6
                            )
                            
                            RequirementRow(
                                text: "Passwords match",
                                isMet: !viewModel.confirmPassword.isEmpty &&
                                       viewModel.registerPassword == viewModel.confirmPassword
                            )
                        }
                        .font(.caption)
                        .padding(.vertical, 8)
                    }
                    
                    // Error Message
                    if let error = viewModel.registerError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    // Success Message
                    if viewModel.isRegistered {
                        Text("Registration successful! Please check your email to verify your account.")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 8)
                    }
                    
                    // Register Button
                    Button(action: viewModel.register) {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.isRegisterValid && !viewModel.isLoading ? Color.green : Color.gray)
                        )
                    }
                    .disabled(!viewModel.isRegisterValid || viewModel.isLoading)
                    .padding(.top, 8)
                    
                    // Terms Agreement
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// Requirement Row Component
struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
                .font(.caption)
            
            Text(text)
                .foregroundColor(isMet ? .green : .gray)
            
            Spacer()
        }
    }
}
struct LoginView: View {
    @ObservedObject var viewModel: AccountViewModel
    @State private var showForgotPassword = false
    
    var body: some View {
        ScrollView {
            ZStack{
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Welcome Back")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Sign in to continue")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter your email", text: $viewModel.loginEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SecureField("Enter your password", text: $viewModel.loginPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Remember Me & Forgot Password
                        HStack {
                            Toggle("Remember Me", isOn: $viewModel.rememberMe)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .font(.caption)
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        // Error Message
                        if let error = viewModel.loginError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                        
                        // Login Button
                        Button(action: viewModel.login) {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.isLoginValid && !viewModel.isLoading ? Color.blue : Color.gray)
                            )
                        }
                        .disabled(!viewModel.isLoginValid || viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Social Login
                    VStack(spacing: 16) {
                        Text("Or continue with")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            SocialLoginButton(icon: "g.circle.fill", color: .red) {
                                // Google login
                            }
                            
                            SocialLoginButton(icon: "applelogo", color: .black) {
                                // Apple login
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

// Social Login Button Component
struct SocialLoginButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
}
class AccountViewModel: ObservableObject {
    // Login Properties
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var rememberMe = false
    @Published var isLoading = false
    @Published var loginError: String?
    
    // Register Properties
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    @Published var registerError: String?
    @Published var isRegistered = false
    
    // Validation
    var isLoginValid: Bool {
        !loginEmail.isEmpty && !loginPassword.isEmpty
    }
    
    var isRegisterValid: Bool {
        !registerEmail.isEmpty &&
        !registerPassword.isEmpty &&
        !fullName.isEmpty &&
        registerPassword == confirmPassword &&
        registerPassword.count >= 6
    }
    
    func login() {
        isLoading = true
        loginError = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            // Add your actual login logic here
            if self.loginEmail == "demo@example.com" && self.loginPassword == "password" {
                print("Login successful")
            } else {
                self.loginError = "Invalid email or password"
            }
        }
    }
    
    func register() {
        isLoading = true
        registerError = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            // Add your actual registration logic here
            if self.registerPassword.count < 6 {
                self.registerError = "Password must be at least 6 characters"
            } else {
                self.isRegistered = true
                print("Registration successful")
            }
        }
    }
}
struct AccountView: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = AccountViewModel()
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Photo
                
                VStack(spacing: 0) {
                    // Animated Tab Selector
                    HStack {
                        AnimatedTabButton(
                            title: "Login",
                            icon: "person.circle.fill",
                            isSelected: selectedTab == 0,
                            animation: animation
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedTab = 0
                            }
                        }
                        
                        AnimatedTabButton(
                            title: "Register",
                            icon: "person.badge.plus",
                            isSelected: selectedTab == 1,
                            animation: animation
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedTab = 1
                            }
                        }
                    }
                    .padding()
                    
                    // Content based on selection with transition
                    ZStack {
                        if selectedTab == 0 {
                            LoginView(viewModel: viewModel)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        } else {
                            RegisterView(viewModel: viewModel)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    
                    Spacer()
                }
                .navigationTitle("Account")
            }
        }
    }
}

// Animated Tab Button Component
struct AnimatedTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Scale down then up for press animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .scaleEffect(isPressed ? 0.8 : 1.0)
                    .rotationEffect(.degrees(isPressed ? -5 : 0))
                
                Text(title)
                    .font(.headline)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .foregroundColor(isSelected ? .white : .blue)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom Button Style for additional press animations
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BouncingTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    @State private var bounce = false
    
    var body: some View {
        Button(action: {
            // Bounce animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                bounce = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    bounce = false
                }
            }
            
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .scaleEffect(bounce ? 1.2 : 1.0)
                
                Text(title)
                    .font(.headline)
                    .scaleEffect(bounce ? 1.1 : 1.0)
            }
            .foregroundColor(isSelected ? .white : .blue)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .matchedGeometryEffect(id: "TAB", in: animation)
                            .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.clear)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 0 : 2
                    )
            )
        }
        .buttonStyle(AdvancedButtonStyle())
    }
}

struct AdvancedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0.0)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.3), value: configuration.isPressed)
    }
}

/*
AnimatedTabButton(
    title: "Login",
    icon: "person.circle.fill",
    isSelected: selectedTab == 0,
    animation: animation
) {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        selectedTab = 0
    }
}
*/

// Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.green : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

#Preview{
    AccountView()
}
