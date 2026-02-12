//
//  CategoryRepositoryProtocol.swift
//  finance
//
//  Protocol defining the interface for category data operations.
//  Used for dependency injection instead of singleton access.
//

import Foundation
import Combine

protocol CategoryRepositoryProtocol: ObservableObject {
    var categories: [SpendingCategory] { get }
    var visibleCategories: [SpendingCategory] { get }

    func visibleCategories(for type: CategoryType) -> [SpendingCategory]
    func categories(for type: CategoryType) -> [SpendingCategory]
    func addCategory(_ category: SpendingCategory)
    func updateCategory(_ category: SpendingCategory)
    func deleteCategory(_ category: SpendingCategory)
    func toggleVisibility(_ category: SpendingCategory)
    func reorderCategories(_ sourceIndices: IndexSet, _ destination: Int, for type: CategoryType)
    func resetToDefaults()
}
