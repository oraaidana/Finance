//
//  FirebaseAuthService.swift
//  finance
//
//  Created on 11/21/25.
//

import Foundation
import FirebaseAuth
import Combine

// MARK: - Authentication Error
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case emailNotVerified
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .userNotFound:
            return "No account found with this email. Please check your email or sign up"
        case .wrongPassword:
            return "Incorrect email or password. Please try again"
        case .networkError:
            return "Network error. Please check your connection and try again"
        case .emailNotVerified:
            return "Please verify your email before logging in"
        case .unknown(let error):
            // Try to extract a user-friendly message from Firebase errors
            let errorString = error.localizedDescription.lowercased()
            if errorString.contains("invalid") && (errorString.contains("credential") || errorString.contains("password")) {
                return "Incorrect email or password. Please try again"
            }
            if errorString.contains("user not found") || errorString.contains("no user record") {
                return "No account found with this email. Please check your email or sign up"
            }
            if errorString.contains("network") || errorString.contains("connection") {
                return "Network error. Please check your connection and try again"
            }
            // Fallback to a generic message instead of raw Firebase error
            return "An error occurred. Please try again"
        }
    }
}

// MARK: - Firebase Auth Service Protocol
protocol AuthServiceProtocol {
    func signUp(email: String, password: String, name: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() throws
    func sendPasswordReset(email: String) async throws
    func confirmPasswordReset(actionCode: String, newPassword: String) async throws
    func sendEmailVerification() async throws
    func applyActionCode(actionCode: String) async throws
    func checkEmailVerification() async throws -> Bool
    func getCurrentUser() -> User?
    func reloadUser() async throws
}

// MARK: - Firebase Auth Service Implementation
class FirebaseAuthService: AuthServiceProtocol {
    static let shared = FirebaseAuthService()
    
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String) async throws -> User {
        // Validate email
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Validate password
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        do {
            // Create user with Firebase
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // Update user profile with display name
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Send email verification
            try await authResult.user.sendEmailVerification()
            
            // Convert Firebase User to our User model
            return User(
                id: authResult.user.uid,
                email: authResult.user.email ?? "",
                name: name,
                isEmailVerified: authResult.user.isEmailVerified
            )
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> User {
        // Validate email
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            // Check if email is verified
            // Note: You might want to allow unverified users to sign in
            // and show a message to verify their email
            // For now, we'll allow it but track the status
            
            // Convert Firebase User to our User model
            return User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? "",
                name: firebaseUser.displayName ?? "",
                isEmailVerified: firebaseUser.isEmailVerified
            )
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String) async throws {
        // Validate email
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Confirm Password Reset
    func confirmPasswordReset(actionCode: String, newPassword: String) async throws {
        guard newPassword.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        do {
            try await auth.confirmPasswordReset(withCode: actionCode, newPassword: newPassword)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Apply Action Code (Email Verification)
    func applyActionCode(actionCode: String) async throws {
        do {
            try await auth.applyActionCode(actionCode)
            // Reload user to update verification status
            if let user = auth.currentUser {
                try await user.reload()
            }
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Email Verification
    func sendEmailVerification() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.sendEmailVerification()
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Check Email Verification
    func checkEmailVerification() async throws -> Bool {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.reload()
            return user.isEmailVerified
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Get Current User
    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else {
            return nil
        }
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            name: firebaseUser.displayName ?? "",
            isEmailVerified: firebaseUser.isEmailVerified
        )
    }
    
    // MARK: - Reload User
    func reloadUser() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.reload()
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        guard let nsError = error as NSError? else {
            // If we can't parse as NSError, check the error description
            let errorDescription = error.localizedDescription.lowercased()
            if errorDescription.contains("invalid") && errorDescription.contains("credential") {
                return .wrongPassword
            }
            if errorDescription.contains("user not found") || errorDescription.contains("no user record") {
                return .userNotFound
            }
            if errorDescription.contains("email") && errorDescription.contains("already") {
                return .emailAlreadyInUse
            }
            return .unknown(error)
        }
        
        // Try to get AuthErrorCode
        if let errorCode = AuthErrorCode(rawValue: nsError.code) {
            switch errorCode {
            case .invalidEmail:
                return .invalidEmail
            case .weakPassword:
                return .weakPassword
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .userNotFound:
                return .userNotFound
            case .wrongPassword:
                return .wrongPassword
            case .invalidCredential, .invalidUserToken:
                // These cover "supplied auth credentials" errors
                return .wrongPassword
            case .networkError:
                return .networkError
            case .tooManyRequests:
                return AuthError.networkError // Rate limiting
            case .userDisabled:
                return AuthError.unknown(error) // Account disabled
            default:
                // Check error description for common patterns
                let errorDescription = nsError.localizedDescription.lowercased()
                if errorDescription.contains("invalid") && (errorDescription.contains("credential") || errorDescription.contains("password")) {
                    return .wrongPassword
                }
                if errorDescription.contains("user not found") || errorDescription.contains("no user record") {
                    return .userNotFound
                }
                if errorDescription.contains("email") && errorDescription.contains("already") {
                    return .emailAlreadyInUse
                }
                return .unknown(error)
            }
        }
        
        // Fallback: check error description for common patterns
        let errorDescription = nsError.localizedDescription.lowercased()
        if errorDescription.contains("invalid") && (errorDescription.contains("credential") || errorDescription.contains("password")) {
            return .wrongPassword
        }
        if errorDescription.contains("user not found") || errorDescription.contains("no user record") {
            return .userNotFound
        }
        if errorDescription.contains("email") && errorDescription.contains("already") {
            return .emailAlreadyInUse
        }
        if errorDescription.contains("network") || errorDescription.contains("connection") {
            return .networkError
        }
        
        return .unknown(error)
    }
}

