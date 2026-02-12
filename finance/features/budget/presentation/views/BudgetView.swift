//
//  BudgetView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//
//  Note: Transaction, TransactionType, TransactionCategory, and ExpenseIncomeType
//  are now defined in core/domain/models/
//

import SwiftUI

// MARK: - Main Budget View

struct BudgetView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @StateObject private var viewModel: BudgetViewModel

    init(viewModel: BudgetViewModel? = nil) {
        // Allow injection for testing, otherwise create with placeholder
        // The actual dataManager binding happens in onAppear
        _viewModel = StateObject(wrappedValue: viewModel ?? BudgetViewModel(dataManager: SharedDataManager()))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Divider()

                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(title: "Income", amount: dataManager.totalIncome, color: .appIncome)
                        StatCard(title: "Expenses", amount: dataManager.totalExpenses, color: .appExpense)
                        StatCard(title: "Balance", amount: dataManager.balance, color: .appPrimary)
                    }

                    Divider()

                    // Search Bar
                    VStack(alignment: .leading) {
                        Text("Search Transactions")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.appTextSecondary)

                            TextField("Search transactions...", text: $viewModel.searchText)
                                .textFieldStyle(PlainTextFieldStyle())

                            if !viewModel.searchText.isEmpty {
                                Button(action: {
                                    viewModel.clearSearch()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.appCardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // Transactions List
                    VStack(alignment: .leading) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Add Transaction Button
                    Button(action: {
                        viewModel.showingAddTransaction = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Transaction")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Financial Assistant")
            .background(Color.appCardBackground)
            .sheet(isPresented: $viewModel.showingAddTransaction) {
                AddTransactionView { newTransaction in
                    viewModel.addTransaction(newTransaction)
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(color)
            Text("$\(amount, specifier: "%.2f")")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(color.opacity(0.05)))
        .cornerRadius(10)
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: BudgetViewModel.iconForCategory(transaction.type))
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(BudgetViewModel.colorForCategory(transaction.type))
                .cornerRadius(8)

            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Text(transaction.category)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount and date
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.isExpense ? .appExpense : .appIncome)

                Text(transaction.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(10)
        .shadow(color: .appShadow, radius: 2)
    }
}

// NOTE: AddTransactionView has been moved to Views/Home/AddTransactionView.swift

#Preview {
    BudgetView()
}
