//
//  Transaction.swift
//  finance
//
//  Core domain model for transactions.
//  Extracted from BudgetView.swift for Clean Architecture.
//

import Foundation

// MARK: - Transaction Model
struct Transaction: Identifiable, Hashable {
    let id: UUID
    let title: String
    let amount: Double
    let category: String
    let date: Date
    let type: TransactionType
    let isExpense: Bool
    let cardId: UUID?
    let destinationCardId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        category: String,
        date: Date,
        type: TransactionType,
        isExpense: Bool,
        cardId: UUID? = nil,
        destinationCardId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.type = type
        self.isExpense = isExpense
        self.cardId = cardId
        self.destinationCardId = destinationCardId
    }

    var formattedAmount: String {
        let sign = isExpense ? "-" : "+"
        return String(format: "%@₸%.0f", sign, abs(amount))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Sample Data
extension Transaction {
    static let sampleData: [Transaction] = []
}
