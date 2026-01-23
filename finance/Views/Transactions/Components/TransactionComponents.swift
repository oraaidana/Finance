//
//  TransactionComponents.swift
//  finance
//
//  Created on 01/28/26.
//

import SwiftUI

// MARK: - Transaction Mode
enum TransactionMode: String, CaseIterable {
    case expense = "EXPENSE"
    case income = "INCOME"

    var categoryType: CategoryType {
        switch self {
        case .income: return .income
        case .expense: return .expense
        }
    }
}

// MARK: - Transaction Type Toggle
struct TransactionTypeToggle: View {
    @Binding var selectedMode: TransactionMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach([TransactionMode.expense, TransactionMode.income], id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(selectedMode == mode ? .white : .appTextSecondary)
                        .frame(width: 70, height: 32)
                        .background(
                            selectedMode == mode
                                ? (mode == .expense ? Color.appExpense : Color.appIncome)
                                : Color.clear
                        )
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.appCardBackground)
        .cornerRadius(20)
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
