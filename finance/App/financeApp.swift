//
//  financeApp.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI
import FirebaseCore

@main
// FinanceApp.swift
struct  financeApp: App {
    // Deep link support - commented out for now
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // @StateObject private var deepLinkManager = DeepLinkManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // Deep link handling - commented out for now
                // .onOpenURL { url in
                //     // Handle deep links
                //     DeepLinkManager.shared.handleURL(url)
                // }
        }
    }
}
