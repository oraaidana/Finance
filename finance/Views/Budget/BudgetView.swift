//
//  BudgetView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

// MARK: - Transaction Model
struct Transaction: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let amount: Double
    let category: String
    let date: Date
    let type: TransactionType
    let isExpense: Bool
    
    var formattedAmount: String {
        let sign = isExpense ? "-" : "+"
        return "\(sign)$\(abs(amount), default: "%.2f")"
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
    static let sampleData: [Transaction] = [
        Transaction(title: "Monthly Salary", amount: 3500.00, category: "Transfer", date: Date().addingTimeInterval(-86400 * 2), type: .transfer, isExpense: false),
        Transaction(title: "Netflix", amount: 15.99, category: "Subscriptions", date: Date().addingTimeInterval(-86400), type: .subscriptions, isExpense: true),
        Transaction(title: "Grocery Shopping", amount: 89.50, category: "Shopping", date: Date().addingTimeInterval(-86400 * 3), type: .shopping, isExpense: true),
        Transaction(title: "Electricity Bill", amount: 120.75, category: "Utilities", date: Date().addingTimeInterval(-86400 * 5), type: .utilities, isExpense: true),
        Transaction(title: "Freelance Work", amount: 850.00, category: "Transfer", date: Date().addingTimeInterval(-86400 * 7), type: .transfer, isExpense: false)
    ]
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
//
//  BudgetView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var searchText: String = ""
    @State private var showingAddTransaction = false
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return dataManager.transactions
        }
        return dataManager.transactions.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Divider()
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(title: "Income", amount: dataManager.totalIncome, color: .green)
                        StatCard(title: "Expenses", amount: dataManager.totalExpenses, color: .red)
                        StatCard(title: "Balance", amount: dataManager.balance, color: .blue)
                    }
                    
                    Divider()
                    
                    // Search Bar
                    VStack(alignment: .leading) {
                        Text("Search Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search transactions...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.white))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Transactions List
                    VStack(alignment: .leading) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add Transaction Button
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Transaction")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Financial Assistant")
            .background(Color(.white))
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView { newTransaction in
                    dataManager.addTransaction(newTransaction)
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
            Image(systemName: iconForCategory(transaction.type))
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(colorForCategory(transaction.type))
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
                    .foregroundColor(transaction.isExpense ? .red : .green)
                
                Text(transaction.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
    
    private func iconForCategory(_ type: TransactionType) -> String {
        switch type {
        case .transfer: return "arrow.left.arrow.right"
        case .subscriptions: return "play.tv"
        case .shopping: return "cart"
        case .food: return "fork.knife"
        case .entertainment: return "film"
        case .utilities: return "bolt"
        case .other: return "dollarsign.circle"
        }
    }
    
    private func colorForCategory(_ type: TransactionType) -> Color {
        switch type {
        case .transfer: return .blue.opacity(0.5)
        case .subscriptions: return .purple.opacity(0.5)
        case .shopping: return .orange.opacity(0.5)
        case .food: return .green.opacity(0.5)
        case .entertainment: return .pink.opacity(0.5)
        case .utilities: return .yellow.opacity(0.5)
        case .other: return .gray.opacity(0.5)
        }
    }
}

// MARK: - Add Transaction View
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Transaction) -> Void
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: TransactionCategory = .shopping
    @State private var transactionType: ExpenseIncomeType = .expense
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Description", text: $title)
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Type", selection: $transactionType) {
                        Text("Expense").tag(ExpenseIncomeType.expense)
                        Text("Income").tag(ExpenseIncomeType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            title: title.isEmpty ? selectedCategory.rawValue : title,
            amount: amountValue,
            category: selectedCategory.rawValue,
            date: date,
            type: selectedCategory.toTransactionType(),
            isExpense: transactionType == .expense
        )
        
        onSave(transaction)
        dismiss()
    }
}

#Preview {
    BudgetView()
}
