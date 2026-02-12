//
//  TransactionComponents.swift
//  finance
//
//  Created on 01/28/26.
//

import SwiftUI

// MARK: - Transaction Mode
enum TransactionMode: String, CaseIterable {
    case income = "Доход"
    case expense = "Расход"
    case transfer = "Перевод"

    var categoryType: CategoryType {
        switch self {
        case .income: return .income
        case .expense, .transfer: return .expense
        }
    }

    var icon: String {
        switch self {
        case .income: return "arrow.down.left"
        case .expense: return "arrow.up.right"
        case .transfer: return "arrow.left.arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .income: return Color(red: 0.2, green: 0.7, blue: 0.4)  // Green
        case .expense: return Color(red: 1.0, green: 0.6, blue: 0.2) // Orange
        case .transfer: return Color(red: 0.2, green: 0.5, blue: 0.9) // Blue
        }
    }
}

// MARK: - Transaction Type Toggle
struct TransactionTypeToggle: View {
    @Binding var selectedMode: TransactionMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach([TransactionMode.income, TransactionMode.expense, TransactionMode.transfer], id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .semibold))

                        if selectedMode == mode {
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(selectedMode == mode ? .white : mode.color)
                    .padding(.horizontal, selectedMode == mode ? 12 : 10)
                    .padding(.vertical, 8)
                    .background(
                        selectedMode == mode
                            ? mode.color.opacity(0.9)
                            : Color.clear
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }
}

// MARK: - Card Pill
struct CardPill: View {
    let card: Card
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: card.icon)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .appTextSecondary)

            Text(card.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .appTextPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isSelected ? card.color.color : Color.appCardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
        )
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: SpendingCategory
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(category.emoji)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(isSelected ? Color.appPrimary.opacity(0.15) : Color.appCardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2.5)
                )

            Text(category.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @Binding var hasPickedDate: Bool

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal)

            Spacer()
        }
        .background(Color.appBackground)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Date Extension
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

// MARK: - Category Icon Button
struct CategoryIconButton: View {
    let emoji: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(emoji)
                .font(.system(size: isSelected ? 24 : 20))
                .frame(width: isSelected ? 56 : 48, height: isSelected ? 56 : 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(isSelected ? 0.4 : 0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Categories Sheet
struct CategoriesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var transactionMode: TransactionMode
    @Binding var selectedCategory: SpendingCategory?
    let getCategories: () -> [SpendingCategory]

    @State private var categories: [SpendingCategory] = []
    @State private var localMode: TransactionMode = .expense

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                toggleSection
                categoriesList
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Категории")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
        }
        .onAppear {
            localMode = transactionMode == .transfer ? .expense : transactionMode
            loadCategories()
        }
        .onChange(of: localMode) { _ in
            loadCategories()
        }
    }

    private var toggleSection: some View {
        HStack {
            Spacer()
            CategoriesToggle(selectedMode: $localMode)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var categoriesList: some View {
        List {
            ForEach(categories) { category in
                CategoryRow(
                    category: category,
                    isSelected: selectedCategory?.id == category.id,
                    onTap: {
                        selectedCategory = category
                        dismiss()
                    }
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onMove { from, to in
                categories.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(.active))
    }

    private var closeButton: some View {
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

    private var addButton: some View {
        Button(action: { }) {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                )
        }
        .buttonStyle(.plain)
    }

    private func loadCategories() {
        if localMode == .income {
            transactionMode = .income
        } else if transactionMode != .transfer {
            transactionMode = .expense
        }
        categories = getCategories()
    }
}

// MARK: - Categories Toggle (Income/Expense only)
struct CategoriesToggle: View {
    @Binding var selectedMode: TransactionMode

    var body: some View {
        HStack(spacing: 0) {
            toggleButton(for: .income)
            toggleButton(for: .expense)
        }
        .padding(4)
        .background(Color(.systemBackground))
        .cornerRadius(24)
    }

    private func toggleButton(for mode: TransactionMode) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMode = mode
            }
        }) {
            toggleContent(for: mode)
        }
        .buttonStyle(.plain)
    }

    private func toggleContent(for mode: TransactionMode) -> some View {
        HStack(spacing: 4) {
            Image(systemName: mode.icon)
                .font(.system(size: 14, weight: .semibold))

            if selectedMode == mode {
                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .foregroundColor(selectedMode == mode ? .white : mode.color)
        .padding(.horizontal, selectedMode == mode ? 12 : 10)
        .padding(.vertical, 8)
        .background(toggleBackground(for: mode))
        .cornerRadius(16)
    }

    private func toggleBackground(for mode: TransactionMode) -> Color {
        selectedMode == mode ? mode.color.opacity(0.9) : Color.clear
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: SpendingCategory
    let isSelected: Bool
    let onTap: () -> Void

    private var categoryColor: Color {
        let colors: [Color] = [
            Color(red: 1.0, green: 0.85, blue: 0.4),  // Yellow
            Color(red: 1.0, green: 0.6, blue: 0.6),   // Pink/Coral
            Color(red: 0.6, green: 0.8, blue: 1.0),   // Light Blue
            Color(red: 0.6, green: 0.9, blue: 0.7),   // Mint
            Color(red: 0.9, green: 0.7, blue: 1.0),   // Lavender
            Color(red: 1.0, green: 0.7, blue: 0.5),   // Peach
            Color(red: 0.7, green: 0.9, blue: 0.9),   // Teal
            Color(red: 0.95, green: 0.8, blue: 0.8),  // Rose
        ]
        let index = abs(category.name.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Text(category.emoji)
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(categoryColor.opacity(0.3))
                    )

                // Category name
                Text(category.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                // Drag handle (shown by List in edit mode)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
