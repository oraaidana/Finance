//
//  HomeAppBar.swift
//  finance
//
//  Extracted from HomeView for Clean Architecture.
//  Custom app bar with account selector and navigation buttons.
//

import SwiftUI

struct HomeAppBar: View {
    let selectedCard: Card?
    let totalBalance: Double
    let formatCurrency: (Double) -> String
    let onAccountPickerTapped: () -> Void

    private var cardColor: Color {
        selectedCard?.color.color ?? .pink
    }

    private var cardIcon: String {
        selectedCard?.icon ?? "piggybank.fill"
    }

    private var cardName: String {
        selectedCard?.name ?? "Все счета"
    }

    private var cardBalance: Double {
        selectedCard?.balance ?? totalBalance
    }

    var body: some View {
        HStack(spacing: 8) {
            // Account selector capsule
            accountSelectorCapsule

            Spacer()

            // History button
            Button(action: {
                // TODO: Show history
            }) {
                CircleButton(iconName: "clock")
            }

            // Analytics/Coins button
            NavigationLink(destination: AnalyticsView()) {
                CircleButton(iconName: "cylinder.split.1x2")
            }

            // Settings button
            NavigationLink(destination: ProfileView()) {
                CircleButton(iconName: "gearshape")
            }
        }
    }

    private var accountSelectorCapsule: some View {
        Button(action: onAccountPickerTapped) {
            HStack(spacing: 8) {
                // Account icon (colored circle with icon)
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: cardIcon)
                        .font(.system(size: 16))
                        .foregroundColor(cardColor)
                }

                // Account info (name + balance)
                VStack(alignment: .leading, spacing: 1) {
                    Text(cardName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(formatCurrency(cardBalance))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.leading, 4)
            .padding(.trailing, 12)
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Circle Button Helper
private struct CircleButton: View {
    let iconName: String

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(.primary)
            .frame(width: 44, height: 44)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
    }
}
