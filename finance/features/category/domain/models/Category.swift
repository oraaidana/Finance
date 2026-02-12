//
//  Category.swift
//  finance
//
//  Created by Claude on 01/24/26.
//

import SwiftUI

enum CategoryType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
}

struct SpendingCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var isVisible: Bool
    var isDefault: Bool
    var order: Int
    var categoryType: CategoryType

    init(id: UUID = UUID(), name: String, emoji: String, isVisible: Bool = true, isDefault: Bool = false, order: Int = 0, categoryType: CategoryType = .expense) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isVisible = isVisible
        self.isDefault = isDefault
        self.order = order
        self.categoryType = categoryType
    }
}

// MARK: - Default Categories
extension SpendingCategory {
    static let defaultExpenseCategories: [SpendingCategory] = [
        SpendingCategory(name: "Fuel", emoji: "⛽️", isVisible: true, isDefault: true, order: 0, categoryType: .expense),
        SpendingCategory(name: "Groceries", emoji: "🛒", isVisible: true, isDefault: true, order: 1, categoryType: .expense),
        SpendingCategory(name: "Cafe", emoji: "☕️", isVisible: true, isDefault: true, order: 2, categoryType: .expense),
        SpendingCategory(name: "Entertainment", emoji: "🎡", isVisible: true, isDefault: true, order: 3, categoryType: .expense),
        SpendingCategory(name: "Shopping", emoji: "🛍️", isVisible: true, isDefault: true, order: 4, categoryType: .expense),
        SpendingCategory(name: "Taxi", emoji: "🚕", isVisible: true, isDefault: true, order: 5, categoryType: .expense),
        SpendingCategory(name: "Home", emoji: "🏠", isVisible: true, isDefault: true, order: 6, categoryType: .expense),
        SpendingCategory(name: "Car", emoji: "🚗", isVisible: true, isDefault: true, order: 7, categoryType: .expense),
        SpendingCategory(name: "Health", emoji: "💊", isVisible: true, isDefault: true, order: 8, categoryType: .expense),
        SpendingCategory(name: "Gifts", emoji: "🎁", isVisible: true, isDefault: true, order: 9, categoryType: .expense),
        SpendingCategory(name: "Education", emoji: "📚", isVisible: true, isDefault: true, order: 10, categoryType: .expense),
        SpendingCategory(name: "Travel", emoji: "✈️", isVisible: true, isDefault: true, order: 11, categoryType: .expense),
        SpendingCategory(name: "Subscriptions", emoji: "📺", isVisible: true, isDefault: true, order: 12, categoryType: .expense),
        SpendingCategory(name: "Other", emoji: "📦", isVisible: true, isDefault: true, order: 13, categoryType: .expense)
    ]

    static let defaultIncomeCategories: [SpendingCategory] = [
        SpendingCategory(name: "Salary", emoji: "💰", isVisible: true, isDefault: true, order: 0, categoryType: .income),
        SpendingCategory(name: "Freelance", emoji: "💻", isVisible: true, isDefault: true, order: 1, categoryType: .income),
        SpendingCategory(name: "Investments", emoji: "📈", isVisible: true, isDefault: true, order: 2, categoryType: .income),
        SpendingCategory(name: "Gift", emoji: "🎀", isVisible: true, isDefault: true, order: 3, categoryType: .income),
        SpendingCategory(name: "Refund", emoji: "↩️", isVisible: true, isDefault: true, order: 4, categoryType: .income),
        SpendingCategory(name: "Bonus", emoji: "🎉", isVisible: true, isDefault: true, order: 5, categoryType: .income),
        SpendingCategory(name: "Rental", emoji: "🏢", isVisible: true, isDefault: true, order: 6, categoryType: .income),
        SpendingCategory(name: "Other", emoji: "💵", isVisible: true, isDefault: true, order: 7, categoryType: .income)
    ]

    static let defaultCategories: [SpendingCategory] = defaultExpenseCategories + defaultIncomeCategories

    static let availableEmojis: [String] = [
        "⛽️", "🛒", "☕️", "🎡", "🛍️", "🚕", "🏠", "🚗", "💊", "🎁",
        "📚", "✈️", "📺", "💸", "💰", "📦", "🍕", "🍔", "🍳", "🎬",
        "🎮", "💻", "📱", "👕", "👟", "💇", "🏥", "🦷", "🐕", "🐈",
        "🌱", "💡", "🔧", "🎂", "💍", "🏋️", "⚽️", "🎸", "🎨", "📸",
        "💵", "📈", "🎀", "↩️", "🎉", "🏢", "💼", "🏦", "💳", "🪙"
    ]
}
