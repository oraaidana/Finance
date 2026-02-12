//
//  AccountPickerView.swift
//  finance
//
//  Created by Claude on 02/12/26.
//

import SwiftUI

struct AccountPickerView: View {
    @ObservedObject var cardManager: CardManager = .shared
    @Binding var selectedIndex: Int
    let formatCurrency: (Double) -> String

    @Environment(\.dismiss) private var dismiss
    @State private var showingAddAccount = false

    private var totalBalance: Double {
        cardManager.cards.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // All accounts row
                allAccountsRow
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // Individual accounts list
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(cardManager.cards.enumerated()), id: \.element.id) { index, card in
                            AccountRowView(
                                card: card,
                                formatCurrency: formatCurrency,
                                onSelect: {
                                    selectedIndex = index
                                    dismiss()
                                },
                                onEdit: {
                                    // TODO: Edit account
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Счета")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            )
                    }
                    .buttonStyle(.plain)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Add account button
                        Button(action: { showingAddAccount = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)

                        // Sort/filter button
                        Button(action: { /* TODO: Sort/filter */ }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView { newCard in
                    cardManager.addCard(newCard)
                }
            }
        }
    }

    // MARK: - All Accounts Row
    private var allAccountsRow: some View {
        Button(action: {
            selectedIndex = 0 // Select first card as default when "all" is tapped
            dismiss()
        }) {
            HStack {
                Text("All Accounts")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Text(formatCurrency(totalBalance))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Account Row View
struct AccountRowView: View {
    let card: Card
    let formatCurrency: (Double) -> String
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Card icon
            Circle()
                .fill(card.color.color.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: card.icon)
                        .font(.system(size: 20))
                        .foregroundColor(card.color.color)
                )

            // Card name
            Text(card.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            // Balance
            Text(formatCurrency(card.balance))
                .font(.system(size: 16))
                .foregroundColor(.primary)

            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    AccountPickerView(
        selectedIndex: .constant(0),
        formatCurrency: { value in
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.groupingSeparator = " "
            return "\(formatter.string(from: NSNumber(value: value)) ?? "0") ₸"
        }
    )
}
