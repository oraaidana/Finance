//
//  RootView.swift
//  finance
//
//  Created on 11/21/25.
//

import SwiftUI

enum AppState {
    case splash
    case onboarding
    case login
    case emailVerification
    case main
}

struct RootView: View {
    @StateObject private var dataManager = SharedDataManager()
    @StateObject private var authManager = AuthManager.shared
    // Deep link support - commented out for now
    // @StateObject private var deepLinkManager = DeepLinkManager.shared
    @State private var appState: AppState = .splash
    @State private var hasSeenOnboarding = OnboardingManager.hasSeenOnboarding
    
    var body: some View {
        ZStack {
            switch appState {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .onboarding:
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .transition(.opacity)
            case .login:
                LoginView()
                    .transition(.opacity)
            case .emailVerification:
                NavigationView {
                    EmailVerificationView()
                }
                .transition(.opacity)
            case .main:
                ContentView()
                    .environmentObject(dataManager)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Show splash for 1 second, then determine next state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    determineNextState()
                }
            }
        }
        .onChange(of: hasSeenOnboarding) { oldValue, newValue in
            // When onboarding is completed, move to login
            if newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState = .login
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            // When user logs in or signs up, check email verification
            if newValue {
                // Small delay to ensure currentUser is set
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let user = authManager.currentUser, !user.isEmailVerified {
                        // Show email verification screen
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState = .emailVerification
                        }
                    } else if authManager.currentUser != nil {
                        // Email verified or user exists, go to main
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState = .main
                        }
                    }
                }
            } else if !newValue && oldValue {
                // When user logs out, return to login
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState = .login
                }
            }
        }
        .onChange(of: authManager.currentUser) { oldValue, newValue in
            // When currentUser changes, check if we need to show verification screen
            // Skip if already in main state (e.g., profile updates shouldn't trigger navigation)
            if appState == .main {
                return
            }
            if let user = newValue, authManager.isAuthenticated {
                if !user.isEmailVerified && appState != .emailVerification {
                    // User is authenticated but email not verified
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState = .emailVerification
                    }
                } else if user.isEmailVerified && appState == .emailVerification {
                    // Email just got verified, go to main
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState = .main
                    }
                }
            }
        }
        .onChange(of: authManager.currentUser?.isEmailVerified) { oldValue, newValue in
            // When email is verified, move to main content
            if newValue == true && appState == .emailVerification {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState = .main
                }
            }
        }
        // Deep link handling - commented out for now
        // .onChange(of: deepLinkManager.shouldNavigate) { oldValue, newValue in
        //     // Handle deep links
        //     if newValue, let destination = deepLinkManager.destination {
        //         handleDeepLink(destination)
        //         deepLinkManager.reset()
        //     }
        // }
    }
    
    // Deep link handler - commented out for now
    // private func handleDeepLink(_ destination: DeepLinkDestination) {
    //     switch destination {
    //     case .forgotPassword:
    //         // Navigate to forgot password (handled in LoginView)
    //         if appState == .login {
    //             // Already on login, navigation will be handled by LoginView
    //         }
    //     case .emailVerification:
    //         appState = .emailVerification
    //     case .verifyEmail(let actionCode):
    //         // Apply email verification action code
    //         Task {
    //             await authManager.applyActionCode(actionCode)
    //             // After verification, check status
    //             if authManager.currentUser?.isEmailVerified == true {
    //                 appState = .main
    //             } else {
    //                 appState = .emailVerification
    //             }
    //         }
    //     case .resetPassword(let token):
    //         // Handle password reset - navigate to login and show reset option
    //         appState = .login
    //         // You might want to show a password reset view here
    //     case .unknown:
    //         break
    //     }
    // }
    
    private func determineNextState() {
        // Check if user is already authenticated
        if authManager.isAuthenticated {
            // Check email verification status
            if let user = authManager.currentUser, !user.isEmailVerified {
                // User is authenticated but email not verified
                appState = .emailVerification
            } else {
                // User is authenticated and email verified (or no user object yet)
                appState = .main
            }
        } else if OnboardingManager.hasSeenOnboarding {
            // User has seen onboarding, go to login
            appState = .login
        } else {
            // User hasn't seen onboarding, show it
            appState = .onboarding
        }
    }
}

#Preview {
    RootView()
}

