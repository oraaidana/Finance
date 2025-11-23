//
//  AuthManager.swift
//  finance
//
//  Created on 11/21/25.
//

import Foundation
import Combine
import FirebaseAuth

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Use Firebase Auth Service
        self.authService = FirebaseAuthService.shared
        
        // Check if user is already authenticated
        checkAuthState()
        
        // Listen to auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if let user = user {
                self?.currentUser = User(
                    id: user.uid,
                    email: user.email ?? "",
                    name: user.displayName ?? "",
                    isEmailVerified: user.isEmailVerified
                )
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    deinit {
        // Remove listener when AuthManager is deallocated
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(email: email, password: password, name: name)
            await MainActor.run {
                // Set user first, then authenticated state
                // This ensures currentUser is set before isAuthenticated triggers navigation
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Sign in an existing user
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            await MainActor.run {
                // Set user first, then authenticated state
                // This ensures currentUser is set before isAuthenticated triggers navigation
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Sign out current user
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    /// Send password reset email
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.sendPasswordReset(email: email)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Send email verification
    func sendEmailVerification() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.sendEmailVerification()
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Apply action code (for email verification from deep link)
    func applyActionCode(_ actionCode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.applyActionCode(actionCode: actionCode)
            // Reload user to get updated verification status
            await reloadUser()
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Confirm password reset with action code
    func confirmPasswordReset(actionCode: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.confirmPasswordReset(actionCode: actionCode, newPassword: newPassword)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Check if email is verified
    func checkEmailVerification() async -> Bool {
        do {
            let isVerified = try await authService.checkEmailVerification()
            await MainActor.run {
                if let user = self.currentUser {
                    self.currentUser = User(
                        id: user.id,
                        email: user.email,
                        name: user.name,
                        isEmailVerified: isVerified
                    )
                }
            }
            return isVerified
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
            }
            return false
        }
    }
    
    /// Reload current user data
    func reloadUser() async {
        do {
            try await authService.reloadUser()
            if let user = authService.getCurrentUser() {
                await MainActor.run {
                    self.currentUser = user
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = (error as? AuthError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthState() {
        if let user = authService.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}

