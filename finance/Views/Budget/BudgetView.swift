//
//  BudgetView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

// MARK: - Transaction Model
struct Transaction: Identifiable, Hashable {
    let id: UUID
    let title: String
    let amount: Double
    let category: String
    let date: Date
    let type: TransactionType
    let isExpense: Bool
    let cardId: UUID?
    let destinationCardId: UUID?

    init(id: UUID = UUID(), title: String, amount: Double, category: String, date: Date, type: TransactionType, isExpense: Bool, cardId: UUID? = nil, destinationCardId: UUID? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.type = type
        self.isExpense = isExpense
        self.cardId = cardId
        self.destinationCardId = destinationCardId
    }

    var formattedAmount: String {
        let sign = isExpense ? "-" : "+"
        return String(format: "%@₸%.0f", sign, abs(amount))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Transaction Type
enum TransactionType {
    case transfer, subscriptions, shopping, food, entertainment, utilities, other
}

// MARK: - Sample Data
extension Transaction {
    static let sampleData: [Transaction] = []
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

// MARK: - Expense/Income Type
enum ExpenseIncomeType {
    case expense, income
}

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
