//
//  ContentView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showingAddTransaction = false

    var body: some View {
        HomeView(showingAddTransaction: $showingAddTransaction)
            .preferredColorScheme(themeManager.colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(SharedDataManager())
}
