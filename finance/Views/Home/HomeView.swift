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
    @State private var isAccountsExpanded: Bool = true

    init(viewModel: HomeViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel(dataManager: SharedDataManager()))
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Cards carousel
                        cardsSection

                        // Quick Stats Cards
                        quickStatsSection

                        // Spending by Category Chart
                        spendingChartSection

                        // Search Bar
                        searchBarSection

                        // Recent Transactions
                        recentTransactionsSection
                    }
                    .padding()
                    .padding(.bottom, 80) // Space for FAB
                }

                // Floating Action Button
                floatingActionButton
            }
            .navigationTitle("Home")
            .background(Color.appBackground)
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
        }
    }

    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        Button(action: { viewModel.showingAddTransaction = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .shadow(color: Color.appShadow.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Accounts Section
    private var cardsSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                Spacer()

                // Add card button
                Button(action: {
                    // TODO: Implement add card
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.appSecondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Expand/collapse button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isAccountsExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.appSecondary)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(isAccountsExpanded ? 0 : 180))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Accounts list
            if isAccountsExpanded {
                if !viewModel.hasCards {
                    emptyAccountsPlaceholder
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                            AccountRow(
                                card: card,
                                isSelected: viewModel.selectedCardIndex == index
                            )
                            .onTapGesture {
                                viewModel.selectedCardIndex = index
                            }

                            if index < viewModel.cards.count - 1 {
                                Divider()
                                    .background(Color.appSecondary)
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }

    // MARK: - Empty Accounts Placeholder
    private var emptyAccountsPlaceholder: some View {
        HStack {
            Image(systemName: "creditcard")
                .font(.title2)
                .foregroundColor(.appTextSecondary)
            Text("No accounts yet")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
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
