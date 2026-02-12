//
//  TransactionListSection.swift
//  finance
//
//  Extracted from HomeView for Clean Architecture.
//  Displays grouped transactions by date.
//

import SwiftUI

struct TransactionListSection: View {
    let groupedTransactions: [HomeViewModel.TransactionGroup]
    let categoryManager: CategoryManager
    let onTransactionTapped: (Transaction) -> Void
    let onDeleteTransaction: (Transaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if groupedTransactions.isEmpty {
                emptyPeriodPlaceholder
            } else {
                ForEach(groupedTransactions) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        // Date header
                        Text(group.dateDisplayText)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)

                        // Transactions for this date
                        VStack(spacing: 0) {
                            ForEach(group.transactions) { transaction in
                                TransactionRowView(
                                    transaction: transaction,
                                    categoryManager: categoryManager
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onTransactionTapped(transaction)
                                }
                                .contextMenu {
                                    Button {
                                        onTransactionTapped(transaction)
                                    } label: {
                                        Label("Редактировать", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        onDeleteTransaction(transaction)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var emptyPeriodPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "slash.circle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("За этот период нет операций")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
