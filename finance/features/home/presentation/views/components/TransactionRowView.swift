//
//  TransactionRowView.swift
//  finance
//
//  Extracted from HomeView for Clean Architecture.
//  Individual transaction row display component.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let categoryManager: CategoryManager

    private var category: SpendingCategory? {
        categoryManager.categories.first { $0.name == transaction.category }
    }

    private var categoryStyle: (icon: String, color: Color) {
        // Map category names to SF Symbols and colors
        let categoryName = transaction.category.lowercased()

        switch categoryName {
        case "cafe", "кафе и рестораны", "кафе", "рестораны":
            return ("fork.knife", Color.red)
        case "health", "здоровье":
            return ("waveform.path.ecg", Color.green)
        case "groceries", "продукты", "еда":
            return ("cart.fill", Color.orange)
        case "shopping", "покупки":
            return ("bag.fill", Color.purple)
        case "transport", "транспорт", "taxi", "такси":
            return ("car.fill", Color.blue)
        case "entertainment", "развлечения":
            return ("gamecontroller.fill", Color.pink)
        case "home", "дом", "жилье":
            return ("house.fill", Color.brown)
        case "subscriptions", "подписки":
            return ("tv.fill", Color.indigo)
        case "education", "образование":
            return ("book.fill", Color.cyan)
        case "travel", "путешествия":
            return ("airplane", Color.teal)
        case "gifts", "подарки":
            return ("gift.fill", Color.red.opacity(0.8))
        case "fuel", "топливо", "бензин":
            return ("fuelpump.fill", Color.gray)
        case "car", "автомобиль":
            return ("car.fill", Color.blue)
        case "salary", "зарплата":
            return ("banknote.fill", Color.green)
        case "freelance", "фриланс":
            return ("laptopcomputer", Color.blue)
        case "investments", "инвестиции":
            return ("chart.line.uptrend.xyaxis", Color.green)
        case "bonus", "бонус":
            return ("star.fill", Color.yellow)
        case "refund", "возврат":
            return ("arrow.uturn.backward", Color.orange)
        default:
            return ("circle.fill", Color.gray)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(categoryStyle.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: categoryStyle.icon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryStyle.color)
            }

            // Category name and note
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if !transaction.title.isEmpty {
                    Text(transaction.title)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Amount
            Text(formatTransactionAmount(transaction.amount, isExpense: transaction.isExpense))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(transaction.isExpense ? .primary : .green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func formatTransactionAmount(_ value: Double, isExpense: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "

        let formattedNumber = formatter.string(from: NSNumber(value: value)) ?? "0"
        let sign = isExpense ? "-" : "+"
        return "\(sign)\(formattedNumber) ₸"
    }
}
