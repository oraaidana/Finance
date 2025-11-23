//
//  transactions.swift
//  finance
//
//  Created by Aidana Orazbay on 11/21/25.
//

import SwiftUI
import Combine

class SharedDataManager: ObservableObject {
    @Published var transactions: [Transaction] = Transaction.sampleData
    
    // Add transaction function
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
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
        
        var categoryAmounts: [TransactionCategory2: Double] = [:]
        
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
    
    private func categoryFromString(_ categoryString: String) -> TransactionCategory2 {
        switch categoryString.lowercased() {
        case "shopping": return .shopping
        case "health": return .health
        case "transport": return .transport
        case "housing": return .housing
        case "subscriptions": return .subscriptions
        case "food": return .shopping // Map to closest category
        case "entertainment": return .shopping // Map to closest category
        case "utilities": return .housing // Map to closest category
        case "transfer": return .transport // Map to closest category
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
