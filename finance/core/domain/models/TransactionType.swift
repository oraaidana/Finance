//
//  TransactionType.swift
//  finance
//
//  Core domain model for transaction types.
//  Extracted from BudgetView.swift for Clean Architecture.
//

import Foundation

// MARK: - Transaction Type
enum TransactionType: String, CaseIterable {
    case transfer
    case subscriptions
    case shopping
    case food
    case entertainment
    case utilities
    case other
}

// MARK: - Expense/Income Type
enum ExpenseIncomeType: String, CaseIterable {
    case expense
    case income
}
