//
//  SettingsView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        List {
            Section {
                ThemeOption(title: "System", value: "system", icon: "iphone", selectedValue: $themeManager.selectedTheme)
                ThemeOption(title: "Light", value: "light", icon: "sun.max.fill", selectedValue: $themeManager.selectedTheme)
                ThemeOption(title: "Dark", value: "dark", icon: "moon.fill", selectedValue: $themeManager.selectedTheme)
            } header: {
                Text("Appearance")
            } footer: {
                Text("Choose how QarzhyAI looks. System will follow your device settings.")
            }
        }
        .navigationTitle("Appearance")
    }
}

// MARK: - Theme Option Row
struct ThemeOption: View {
    let title: String
    let value: String
    let icon: String
    @Binding var selectedValue: String

    var body: some View {
        Button(action: {
            selectedValue = value
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(selectedValue == value ? .blue : .secondary)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                if selectedValue == value {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
