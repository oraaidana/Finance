// finappApp.swift

import SwiftUI

@main
struct financeApp: App {
    @StateObject private var dataManager = SharedDataManager()
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .preferredColorScheme(.light)   // ← light theme
        }
    }
}

// MARK: - Root View (Auth Gate)
struct RootView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            if authManager.isAuthenticated {
                ContentView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                AuthRootView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal:   .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authManager.isAuthenticated)
    }
}
