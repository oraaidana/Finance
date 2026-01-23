//
//  CategoryManagerView.swift
//  finance
//
//  Created by Claude on 01/24/26.
//

import SwiftUI

struct CategoryManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var categoryManager = CategoryManager.shared

    let categoryType: CategoryType

    @State private var showAddCategory = false
    @State private var editingCategory: SpendingCategory?
    @State private var categoryToDelete: SpendingCategory?
    @State private var showDeleteAlert = false

    init(categoryType: CategoryType = .expense) {
        self.categoryType = categoryType
    }

    var filteredCategories: [SpendingCategory] {
        categoryManager.categories(for: categoryType)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(filteredCategories) { category in
                        CategoryManagerRow(
                            category: category,
                            onToggleVisibility: {
                                categoryManager.toggleVisibility(category)
                            },
                            onEdit: {
                                editingCategory = category
                            },
                            onDelete: {
                                categoryToDelete = category
                                showDeleteAlert = true
                            }
                        )
                    }
                    .onMove { source, destination in
                        categoryManager.reorderCategories(source, destination, for: categoryType)
                    }
                }
                .listStyle(.plain)

                // Add category button
                Button(action: { showAddCategory = true }) {
                    Text("Add category")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appPrimary)
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
                .padding(20)
            }
            .navigationTitle(categoryType == .expense ? "Expense Categoris" : "Income Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    categoryManager.deleteCategory(category)
                }
            }
        } message: {
            Text("Are you sure you want to delete this category?")
        }
        .sheet(isPresented: $showAddCategory) {
            AddEditCategoryView(mode: .add, categoryType: categoryType) { newCategory in
                categoryManager.addCategory(newCategory)
            }
            .presentationDetents([.height(320)])
        }
        .sheet(item: $editingCategory) { category in
            AddEditCategoryView(mode: .edit(category), categoryType: categoryType) { updatedCategory in
                categoryManager.updateCategory(updatedCategory)
            }
            .presentationDetents([.height(320)])
        }
    }
}

#Preview {
    CategoryManagerView(categoryType: .expense)
}
