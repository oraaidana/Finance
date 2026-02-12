//
//  AddAccountView.swift
//  finance
//
//  Created by Claude on 02/12/26.
//

import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var accountName: String = ""
    @State private var selectedColor: Color = .black
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var balance: String = "0"
    @State private var currency: String = "KZT"

    var onSave: ((Card) -> Void)?

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

    // Available icons organized by category
    private let foodIcons = [
        "apple.logo", "birthday.cake.fill", "cup.and.saucer.fill", "oval.fill",
        "car.fill", "pawprint.fill", "basket.fill", "fork.knife",
        "leaf.fill", "carrot.fill", "fish.fill", "takeoutbag.and.cup.and.straw.fill"
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
            .navigationTitle("Новый счет")
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
        VStack(spacing: 0) {
            // Category labels
            HStack {
                Text("Еда")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Транспорт")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Horizontal scrolling icon grid
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(44), spacing: 8), count: 4), spacing: 12) {
                    ForEach(allIcons, id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(selectedIcon == icon ? selectedColor : .primary)
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
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // All icons in a flat array for horizontal scrolling
    private var allIcons: [String] {
        [
            // Food
            "fork.knife", "cup.and.saucer.fill", "mug.fill", "wineglass.fill",
            "cart.fill", "basket.fill", "bag.fill", "takeoutbag.and.cup.and.straw.fill",
            "birthday.cake.fill", "carrot.fill", "leaf.fill", "fish.fill",
            "flame.fill", "drop.fill", "snowflake", "sun.max.fill",
            // Transport
            "car.fill", "bus.fill", "tram.fill", "bicycle",
            "airplane", "ferry.fill", "fuelpump.fill", "parkingsign",
            // Finance
            "creditcard.fill", "banknote.fill", "building.columns.fill", "wallet.pass.fill",
            "chart.pie.fill", "dollarsign.circle.fill", "percent", "chart.line.uptrend.xyaxis",
            // Home
            "house.fill", "sofa.fill", "lamp.desk.fill", "tv.fill",
            "washer.fill", "refrigerator.fill", "bed.double.fill", "bathtub.fill",
            // Health
            "heart.fill", "pills.fill", "cross.case.fill", "figure.walk",
            "dumbbell.fill", "figure.run", "sportscourt.fill", "tennis.racket",
            // Entertainment
            "gamecontroller.fill", "film.fill", "music.note", "ticket.fill",
            "gift.fill", "party.popper.fill", "balloon.fill", "camera.fill",
            // Other
            "briefcase.fill", "graduationcap.fill", "book.fill", "wrench.fill",
            "pawprint.fill", "tshirt.fill", "scissors", "paintbrush.fill",
            "phone.fill", "envelope.fill", "globe", "star.fill",
            "piggybank.fill", "lock.fill", "key.fill", "tag.fill"
        ]
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

        let newCard = Card(
            name: accountName.isEmpty ? "Новый счет" : accountName,
            currency: currency,
            balance: balanceValue,
            color: cardColor,
            icon: selectedIcon
        )

        onSave?(newCard)
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
}

#Preview {
    AddAccountView()
}
