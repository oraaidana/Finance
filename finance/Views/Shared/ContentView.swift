//
//  ContentView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        TabView {
            // Home - Main dashboard with transactions
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // Analytics - Charts and insights
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }

            // Chat - AI financial assistant
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }

            // Profile - User settings
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.appPrimary)
        .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(SharedDataManager())
}
