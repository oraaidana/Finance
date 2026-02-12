//
//  HomeView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//  Merged Dashboard + Budget into unified Home view
//

import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var authManager = AuthManager.shared
    @State private var showingAccountPicker: Bool = false

    init(viewModel: HomeViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel(dataManager: SharedDataManager()))
    }

    private var avatarInitial: String {
        let name = authManager.currentUser?.name ?? ""
        if name.isEmpty {
            let email = authManager.currentUser?.email ?? ""
            return String(email.prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    private var currentDayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Custom App Bar
                    customAppBar
                    
                    

//                    // Quick Stats Cards
//                    quickStatsSection
//
//                    // Spending by Category Chart
//                    spendingChartSection
//
//                    // Search Bar
//                    searchBarSection
//
//                    // Recent Transactions
//                    recentTransactionsSection
                }
                .padding()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.showingAddTransaction) {
                AddTransactionView { newTransaction in
                    viewModel.addTransaction(newTransaction)
                }
                .background(BackgroundClearView())
            }
            .fullScreenCover(item: $viewModel.transactionToEdit) { transaction in
                AddTransactionView(
                    transactionToEdit: transaction,
                    onSave: { updatedTransaction in
                        viewModel.updateTransaction(updatedTransaction)
                    },
                    onDelete: { transactionToDelete in
                        viewModel.deleteTransaction(transactionToDelete)
                    }
                )
                .background(BackgroundClearView())
            }
            .sheet(isPresented: $viewModel.showingImportStatement) {
                BankStatementUploadView()
            }
            .sheet(isPresented: $showingAccountPicker) {
                AccountPickerView(
                    selectedIndex: $viewModel.selectedCardIndex,
                    formatCurrency: viewModel.formatCurrency
                )
            }
        }
    }

    // MARK: - Account Selector Capsule
    private var accountSelectorCapsule: some View {
        let card = viewModel.selectedCard
        let cardColor = card?.color.color ?? .pink
        let cardIcon = card?.icon ?? "piggybank.fill"
        let cardName = card?.name ?? "Все счета"
        let cardBalance = card?.balance ?? viewModel.totalBalance

        return Button(action: {
            showingAccountPicker = true
        }) {
            HStack(spacing: 8) {
                // Account icon (colored circle with icon)
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: cardIcon)
                        .font(.system(size: 16))
                        .foregroundColor(cardColor)
                }

                // Account info (name + balance)
                VStack(alignment: .leading, spacing: 1) {
                    Text(cardName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(viewModel.formatCurrency(cardBalance))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.leading, 4)
            .padding(.trailing, 12)
            .padding(.vertical, 4)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom App Bar
    private var customAppBar: some View {
        HStack(spacing: 8) {
            // Account selector capsule
            accountSelectorCapsule

            Spacer()

            // History button
            Button(action: {
                // TODO: Show history
            }) {
                Image(systemName: "clock")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }

            // Analytics/Coins button
            NavigationLink(destination: AnalyticsView()) {
                Image(systemName: "cylinder.split.1x2")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }

            // Settings button
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            // Balance Card (prominent)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(viewModel.formatCurrency(viewModel.totalBalance))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(viewModel.totalBalance >= 0 ? .appTextPrimary : .appExpense)
                }
                Spacer()
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appPrimary)
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(16)

            // Income & Expense Cards
            HStack(spacing: 12) {
                QuickStatCard(
                    title: "Income",
                    amount: viewModel.totalIncome,
                    icon: "arrow.down.circle.fill",
                    color: .appIncome
                )

                QuickStatCard(
                    title: "Expenses",
                    amount: viewModel.totalExpenses,
                    icon: "arrow.up.circle.fill",
                    color: .appExpense
                )
            }
        }
    }

    // MARK: - Spending Chart Section
    private var spendingChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.horizontal, 4)

            if viewModel.totalExpenses > 0 {
                Chart {
                    ForEach(viewModel.categorySpending) { category in
                        SectorMark(
                            angle: .value("Spending", category.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(category.category.color)
                        .annotation(position: .overlay) {
                            if category.percentage > 0.05 {
                                Text("\(Int(category.percentage * 100))%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: 180)

                // Category Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(viewModel.categorySpending) { categorySpending in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(categorySpending.category.color)
                                .frame(width: 10, height: 10)
                            Text(categorySpending.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.formatCurrency(categorySpending.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                emptyChartPlaceholder
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }


    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appTextSecondary)

            TextField("Search transactions...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(10)
    }

    // MARK: - Recent Transactions Section
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.transactionCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)

            if viewModel.filteredTransactions.isEmpty {
                emptyTransactionsPlaceholder
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        HomeTransactionRow(
                            transaction: transaction,
                            categoryManager: viewModel.getCategoryManager()
                        )
                        .onTapGesture {
                            viewModel.transactionToEdit = transaction
                        }
                        .contextMenu {
                            Button {
                                viewModel.transactionToEdit = transaction
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                viewModel.deleteTransaction(transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty States
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.appTextSecondary)
            Text("No expenses yet")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }

    private var emptyTransactionsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.appTextSecondary)
            Text("No transactions")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Text("Add your first transaction to get started")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }

}

// MARK: - Safe Array Access
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    HomeView()
        .environmentObject(SharedDataManager())
}
