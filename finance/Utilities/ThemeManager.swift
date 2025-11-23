//
//  ThemeManager.swift
//  finance
//
//  Created by Claude on 01/23/26.
//

import SwiftUI
import Combine

/// Manages app-wide theme settings (light/dark/system)
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedTheme: String {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }

    init() {
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "system"
    }

    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }
}
