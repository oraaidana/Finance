//
//  AccountFormView.swift
//  finance
//
//  Created by Claude on 02/12/26.
//

import SwiftUI

// MARK: - Form Mode
enum AccountFormMode {
    case add
    case edit(Card)

    var isEditing: Bool {
        if case .edit = self { return true }
        return false
    }

    var card: Card? {
        if case .edit(let card) = self { return card }
        return nil
    }
}

struct AccountFormView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: AccountFormMode
    var onSave: ((Card) -> Void)?
    var onDelete: (() -> Void)?

    @State private var accountName: String
    @State private var selectedColor: Color
    @State private var selectedIcon: String
    @State private var balance: String
    @State private var currency: String
    @State private var showDeleteAlert = false

    // Store original card ID for editing
    private let cardId: UUID?

    // MARK: - Init
    init(mode: AccountFormMode, onSave: ((Card) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete

        // Pre-fill values based on mode
        switch mode {
        case .add:
            _accountName = State(initialValue: "")
            _selectedColor = State(initialValue: .black)
            _selectedIcon = State(initialValue: "creditcard.fill")
            _balance = State(initialValue: "0")
            _currency = State(initialValue: "KZT")
            cardId = nil

        case .edit(let card):
            _accountName = State(initialValue: card.name)
            _selectedColor = State(initialValue: AccountFormView.cardColorToColor(card.color))
            _selectedIcon = State(initialValue: card.icon)
            _balance = State(initialValue: String(format: "%.2f", card.balance))
            _currency = State(initialValue: card.currency)
            cardId = card.id
        }
    }

    // Available colors
    private let colors: [Color] = [
        .black,
        Color(red: 1.0, green: 0.2, blue: 0.2),      // Red
        Color(red: 1.0, green: 0.4, blue: 0.3),      // Coral
        Color(red: 1.0, green: 0.6, blue: 0.2),      // Orange
        Color(red: 1.0, green: 0.8, blue: 0.0),      // Yellow
        Color(red: 0.6, green: 0.8, blue: 0.2),      // Lime
        Color(red: 0.2, green: 0.8, blue: 0.4),      // Green
        Color(red: 0.2, green: 0.7, blue: 0.6),      // Teal
        Color(red: 0.2, green: 0.6, blue: 0.8),      // Cyan
        Color(red: 0.3, green: 0.5, blue: 0.9),      // Blue
        Color(red: 0.4, green: 0.6, blue: 1.0),      // Light Blue
    ]

    private let iconCategories: [(name: String, icons: [String])] = [
        ("Еда", ["fork.knife", "cup.and.saucer.fill", "cart.fill", "basket.fill", "takeoutbag.and.cup.and.straw.fill", "birthday.cake.fill", "carrot.fill", "leaf.fill"]),
        ("Транспорт", ["car.fill", "bus.fill", "tram.fill", "bicycle", "airplane", "fuelpump.fill"]),
        ("Финансы", ["creditcard.fill", "banknote.fill", "building.columns.fill", "wallet.pass.fill", "chart.pie.fill", "dollarsign.circle.fill"]),
        ("Дом", ["house.fill", "sofa.fill", "lamp.desk.fill", "tv.fill", "washer.fill", "refrigerator.fill"]),
        ("Здоровье", ["heart.fill", "pills.fill", "cross.case.fill", "figure.walk", "dumbbell.fill"]),
        ("Развлечения", ["gamecontroller.fill", "film.fill", "music.note", "ticket.fill", "gift.fill"]),
        ("Другое", ["bag.fill", "tshirt.fill", "graduationcap.fill", "book.fill", "wrench.fill", "pawprint.fill"])
    ]

    private var navigationTitle: String {
        switch mode {
        case .add:
            return "Новый счет"
        case .edit(let card):
            return card.name
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Account name input
                        accountNameField
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)

                        // Color picker
                        colorPicker

                        // Icon picker
                        iconPicker

                        // Balance and Currency
                        balanceAndCurrencySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }

                // Save button at bottom
                saveButton
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(navigationTitle)
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

                // Delete button only in edit mode
                if mode.isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .alert("Удалить счет?", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
            } message: {
                Text("Это действие нельзя отменить. Все данные счета будут удалены.")
            }
        }
    }

    // MARK: - Account Name Field
    private var accountNameField: some View {
        HStack(spacing: 12) {
            // Icon preview
            Circle()
                .fill(selectedColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: selectedIcon)
                        .font(.system(size: 18))
                        .foregroundColor(selectedColor)
                )

            // Text field
            TextField("New Account", text: $accountName)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Color Picker
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                .padding(4)
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? color : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Icon Picker
    private var iconPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 24) {
                ForEach(iconCategories, id: \.name) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        // Category label stuck to its icons
                        Text(category.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)

                        // Icons grid for this category (2 columns x 4 rows)
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 8), count: 2), spacing: 8) {
                            ForEach(category.icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .gray.opacity(0.8))
                                    .frame(width: 38, height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.clear)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Balance and Currency Section
    private var balanceAndCurrencySection: some View {
        VStack(spacing: 0) {
            // Balance row
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 32)

                Text("Баланс")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                TextField("0", text: $balance)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()
                .padding(.leading, 56)

            // Currency row
            HStack {
                Image(systemName: "coloncurrencysign.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 32)

                Text("Валюта")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Text("(по умолчанию) \(currency)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveAccount) {
            Text("Сохранить")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.black)
                .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Actions
    private func saveAccount() {
        let balanceValue = Double(balance) ?? 0
        let cardColor = colorToCardColor(selectedColor)

        let card = Card(
            id: cardId ?? UUID(),  // Keep original ID when editing
            name: accountName.isEmpty ? "Новый счет" : accountName,
            currency: currency,
            balance: balanceValue,
            color: cardColor,
            icon: selectedIcon
        )

        onSave?(card)
        dismiss()
    }

    private func colorToCardColor(_ color: Color) -> CardColor {
        // Map to closest CardColor
        if color == .black { return .blue }
        if color == colors[1] || color == colors[2] { return .red }
        if color == colors[3] || color == colors[4] { return .orange }
        if color == colors[5] || color == colors[6] { return .green }
        if color == colors[7] { return .teal }
        if color == colors[8] || color == colors[9] || color == colors[10] { return .blue }
        return .blue
    }

    // Convert CardColor back to Color for editing
    private static func cardColorToColor(_ cardColor: CardColor) -> Color {
        switch cardColor {
        case .red: return Color(red: 1.0, green: 0.2, blue: 0.2)
        case .orange: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .green: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .teal: return Color(red: 0.2, green: 0.7, blue: 0.6)
        case .blue: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .purple: return .purple
        case .pink: return .pink
        }
    }
}

// MARK: - Convenience initializers
extension AccountFormView {
    /// Create a form for adding a new account
    static func addAccount(onSave: @escaping (Card) -> Void) -> AccountFormView {
        AccountFormView(mode: .add, onSave: onSave)
    }

    /// Create a form for editing an existing account
    static func editAccount(_ card: Card, onSave: @escaping (Card) -> Void, onDelete: @escaping () -> Void) -> AccountFormView {
        AccountFormView(mode: .edit(card), onSave: onSave, onDelete: onDelete)
    }
}

// MARK: - Legacy support (typealias for backward compatibility)
typealias AddAccountView = AccountFormView

#Preview("Add Account") {
    AccountFormView(mode: .add)
}

#Preview("Edit Account") {
    AccountFormView(mode: .edit(Card(name: "Kaspi Gold", currency: "KZT", balance: 150000, color: .orange, icon: "creditcard.fill")))
}
