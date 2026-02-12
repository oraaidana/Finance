//
//  AccountPickerView.swift
//  finance
//
//  Created by Claude on 02/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct AccountPickerView: View {
    @ObservedObject var cardManager: CardManager = .shared
    @Binding var selectedIndex: Int
    let formatCurrency: (Double) -> String

    @Environment(\.dismiss) private var dismiss
    @State private var showingAddAccount = false
    @State private var cardToEdit: Card?
    @State private var isReorderMode = false
    @State private var draggingCard: Card?

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
                                isReorderMode: isReorderMode,
                                isDragging: draggingCard?.id == card.id,
                                onSelect: {
                                    if !isReorderMode {
                                        selectedIndex = index
                                        dismiss()
                                    }
                                },
                                onEdit: {
                                    if !isReorderMode {
                                        cardToEdit = card
                                    }
                                },
                                onDrag: {
                                    draggingCard = card
                                },
                                onDrop: { targetCard in
                                    if let fromCard = draggingCard,
                                       let fromIndex = cardManager.cards.firstIndex(where: { $0.id == fromCard.id }),
                                       let toIndex = cardManager.cards.firstIndex(where: { $0.id == targetCard.id }) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            cardManager.moveCards(from: IndexSet(integer: fromIndex), to: toIndex > fromIndex ? toIndex + 1 : toIndex)
                                        }
                                    }
                                    draggingCard = nil
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
                        // Add account button (hidden in reorder mode)
                        Button(action: { showingAddAccount = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)

                        // Reorder/Done button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isReorderMode.toggle()
                                draggingCard = nil
                            }
                        }) {
                            if isReorderMode {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                            } else {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AccountFormView(mode: .add) { newCard in
                    cardManager.addCard(newCard)
                }
            }
            .sheet(item: $cardToEdit) { card in
                AccountFormView(
                    mode: .edit(card),
                    onSave: { updatedCard in
                        cardManager.updateCard(updatedCard)
                    },
                    onDelete: {
                        cardManager.deleteCard(card)
                    }
                )
            }
        }
    }

    // MARK: - All Accounts Row
    private var allAccountsRow: some View {
        Button(action: {
            if !isReorderMode {
                selectedIndex = 0
                dismiss()
            }
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
        .opacity(isReorderMode ? 0.5 : 1)
        .disabled(isReorderMode)
    }
}

// MARK: - Account Row View
struct AccountRowView: View {
    let card: Card
    let formatCurrency: (Double) -> String
    let isReorderMode: Bool
    let isDragging: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDrag: () -> Void
    let onDrop: (Card) -> Void

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

            // Edit button or drag handle
            if isReorderMode {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
            } else {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .opacity(isDragging ? 0.6 : 1)
        .scaleEffect(isDragging ? 1.02 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onDrag {
            onDrag()
            return NSItemProvider(object: card.id.uuidString as NSString)
        }
        .onDrop(of: [.text], delegate: CardDropDelegate(card: card, onDrop: onDrop))
    }
}

// MARK: - Drop Delegate
struct CardDropDelegate: DropDelegate {
    let card: Card
    let onDrop: (Card) -> Void

    func performDrop(info: DropInfo) -> Bool {
        onDrop(card)
        return true
    }

    func dropEntered(info: DropInfo) {
        // Optional: Add visual feedback when dragging over
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
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
