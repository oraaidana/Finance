//
//  TransactionRepositoryProtocol.swift
//  finance
//
//  Protocol defining the interface for transaction data operations.
//  Used for dependency injection instead of singleton access.
//

import Foundation
import Combine

protocol TransactionRepositoryProtocol: ObservableObject {
    var transactions: [Transaction] { get }

    func addTransaction(_ transaction: Transaction)
    func deleteTransaction(_ transaction: Transaction)
    func updateTransaction(_ transaction: Transaction)

    // Computed properties
    var totalIncome: Double { get }
    var totalExpenses: Double { get }
    var balance: Double { get }
    var categorySpending: [CategorySpending] { get }
    var thisMonthExpenses: Double { get }
    var lastMonthExpenses: Double { get }
    var monthlyTrend: TrendDirection { get }
}
