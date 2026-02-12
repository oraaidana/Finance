//
//  CategorySpending.swift
//  finance
//
//  Core domain model for category spending analytics.
//  Extracted from Dashboard.swift for Clean Architecture.
//

import SwiftUI

// MARK: - Category Spending Model
struct CategorySpending: Identifiable {
    let id: UUID
    let category: TransactionCategory
    let amount: Double
    let percentage: Double

    init(category: TransactionCategory, amount: Double, percentage: Double) {
        self.id = UUID()
        self.category = category
        self.amount = amount
        self.percentage = percentage
    }

    var formattedAmount: String {
        String(format: "$%.2f", amount)
    }

    var formattedPercentage: String {
        "\(Int(percentage * 100))%"
    }
}

// MARK: - Transaction Category
enum TransactionCategory: String, CaseIterable {
    case shopping = "Shopping"
    case health = "Health"
    case transport = "Transport"
    case transfer = "Transfer"
    case housing = "Housing"
    case subscriptions = "Subscriptions"
    case food = "Food"
    case entertainment = "Entertainment"
    case utilities = "Utilities"

    func toTransactionType() -> TransactionType {
        switch self {
        case .shopping: return .shopping
        case .health: return .other
        case .transport: return .other
        case .transfer: return .transfer
        case .housing: return .utilities
        case .subscriptions: return .subscriptions
        case .food: return .food
        case .entertainment: return .entertainment
        case .utilities: return .utilities
        }
    }

    var iconName: String {
        switch self {
        case .shopping: return "cart"
        case .health: return "heart"
        case .transport: return "car"
        case .transfer: return "arrow.left.arrow.right"
        case .housing: return "house"
        case .subscriptions: return "play.tv"
        case .food: return "fork.knife"
        case .entertainment: return "film"
        case .utilities: return "bolt"
        }
    }

    var color: Color {
        switch self {
        case .shopping: return .orange
        case .health: return .pink
        case .transport: return .blue
        case .transfer: return .purple
        case .housing: return .brown
        case .subscriptions: return .red
        case .food: return .green
        case .entertainment: return .indigo
        case .utilities: return .yellow
        }
    }
}
