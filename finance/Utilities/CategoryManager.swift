//
//  CategoryManager.swift
//  finance
//
//  Created by Claude on 01/24/26.
//

import SwiftUI
import Combine

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()

    @Published var categories: [SpendingCategory] = []

    private let categoriesKey = "user_categories_v2"

    var visibleCategories: [SpendingCategory] {
        categories.filter { $0.isVisible }.sorted { $0.order < $1.order }
    }

    func visibleCategories(for type: CategoryType) -> [SpendingCategory] {
        categories
            .filter { $0.isVisible && $0.categoryType == type }
            .sorted { $0.order < $1.order }
    }

    func categories(for type: CategoryType) -> [SpendingCategory] {
        categories
            .filter { $0.categoryType == type }
            .sorted { $0.order < $1.order }
    }

    init() {
        loadCategories()
    }

    // MARK: - Category CRUD

    func addCategory(_ category: SpendingCategory) {
        var newCategory = category
        newCategory.order = categories.filter { $0.categoryType == category.categoryType }.count
        categories.append(newCategory)
        saveCategories()
    }

    func updateCategory(_ category: SpendingCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(_ category: SpendingCategory) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }

    func toggleVisibility(_ category: SpendingCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].isVisible.toggle()
            saveCategories()
        }
    }

    func reorderCategories(_ sourceIndices: IndexSet, _ destination: Int, for type: CategoryType) {
        var sorted = categories(for: type)
        sorted.move(fromOffsets: sourceIndices, toOffset: destination)

        // Update order values
        for (index, category) in sorted.enumerated() {
            if let catIndex = categories.firstIndex(where: { $0.id == category.id }) {
                categories[catIndex].order = index
            }
        }
        saveCategories()
    }

    // MARK: - Persistence

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([SpendingCategory].self, from: data) {
            categories = decoded
        } else {
            // Load default categories for first time
            categories = SpendingCategory.defaultCategories
            saveCategories()
        }
    }

    func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: categoriesKey)
        categories = SpendingCategory.defaultCategories
        saveCategories()
    }
}
