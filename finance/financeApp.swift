//
//  financeApp.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

@main
// FinanceApp.swift
struct  financeApp: App {
    @StateObject private var dataManager = SharedDataManager()
    //@StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                //.environmentObject(authManager)
        }
    }
}
