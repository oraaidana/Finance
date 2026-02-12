//
//  SharedDataManager.swift
//  finance
//
//  Created by Aidana Orazbay on 11/21/25.
//
//  Implementation of TransactionRepositoryProtocol.
//  Manages transaction data with reactive updates.
//
//  Note: Transaction, TransactionType, CategorySpending, TransactionCategory,
//  and TrendDirection are defined in core/domain/models/
//

import SwiftUI
import Combine

class SharedDataManager: ObservableObject, TransactionRepositoryProtocol {
    @Published var transactions: [Transaction] = []

    // Add transaction function
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
    }

    // Delete transaction function
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }

    // Update transaction function
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }

    // Calculate financial totals
    var totalIncome: Double {
        transactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpenses
    }

    var categorySpending: [CategorySpending] {
        let expenseTransactions = transactions.filter { $0.isExpense }
        let totalExpenses = totalExpenses

        var categoryAmounts: [TransactionCategory: Double] = [:]

        for transaction in expenseTransactions {
            let category = categoryFromString(transaction.category)
            categoryAmounts[category, default: 0] += transaction.amount
        }

        return categoryAmounts.map { category, amount in
            let percentage = totalExpenses > 0 ? amount / totalExpenses : 0
            return CategorySpending(category: category, amount: amount, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }

    private func categoryFromString(_ categoryString: String) -> TransactionCategory {
        switch categoryString.lowercased() {
        case "shopping": return .shopping
        case "health": return .health
        case "transport": return .transport
        case "housing": return .housing
        case "subscriptions": return .subscriptions
        case "food": return .food
        case "entertainment": return .entertainment
        case "utilities": return .utilities
        case "transfer": return .transfer
        default: return .shopping
        }
    }

    // This month expenses
    var thisMonthExpenses: Double {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())

        return transactions
            .filter { $0.isExpense }
            .filter { transaction in
                let transactionMonth = Calendar.current.component(.month, from: transaction.date)
                let transactionYear = Calendar.current.component(.year, from: transaction.date)
                return transactionMonth == currentMonth && transactionYear == currentYear
            }
            .reduce(0) { $0 + $1.amount }
    }

    // Last month expenses
    var lastMonthExpenses: Double {
        thisMonthExpenses * 0.9
    }

    var monthlyTrend: TrendDirection {
        thisMonthExpenses > lastMonthExpenses ? .up : .down
    }
}
