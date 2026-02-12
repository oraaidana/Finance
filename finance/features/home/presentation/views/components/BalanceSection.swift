//
//  BalanceSection.swift
//  finance
//
//  Extracted from HomeView for Clean Architecture.
//  Displays balance with period selector and income/expense summary.
//

import SwiftUI

struct BalanceSection: View {
    let periodBalance: Double
    let periodIncome: Double
    let periodExpenses: Double
    let selectedPeriod: PeriodType
    let periodDisplayText: String
    let onPeriodChanged: (PeriodType) -> Void
    let onMovePeriodBackward: () -> Void
    let onMovePeriodForward: () -> Void
    let onResetPeriodOffset: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Period Selector Row
            periodSelectorRow

            // Balance Amount
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatBalanceAmount(periodBalance))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                Text("₸")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.primary)
            }

            // Income and Expense Row
            incomeExpenseRow
        }
        .padding(.top, 8)
    }

    private var periodSelectorRow: some View {
        HStack(spacing: 8) {
            Text("Баланс за")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            // Period selector with navigation arrows
            HStack(spacing: 0) {
                // Back arrow (only for navigable periods)
                if selectedPeriod.canNavigate {
                    Button(action: onMovePeriodBackward) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }

                // Period picker button
                Menu {
                    ForEach(PeriodType.allCases.filter { $0 != .custom }) { period in
                        Button(action: {
                            onPeriodChanged(period)
                            onResetPeriodOffset()
                        }) {
                            HStack {
                                Text(period.rawValue)
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }

                    Divider()

                    Text("Пользовательский")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        onPeriodChanged(.custom)
                    }) {
                        Label("Добавить", systemImage: "plus")
                    }
                } label: {
                    Text(periodDisplayText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }

                // Forward arrow (only for navigable periods)
                if selectedPeriod.canNavigate {
                    Button(action: onMovePeriodForward) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
    }

    private var incomeExpenseRow: some View {
        HStack(spacing: 24) {
            // Income
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
                Text(formatCompactAmount(periodIncome))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
                Text("₸")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }

            // Expense
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                Text(formatCompactAmount(periodExpenses))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.orange)
                Text("₸")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
        }
    }

    // MARK: - Formatting Helpers
    private func formatBalanceAmount(_ value: Double) -> String {
        let absValue = abs(value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "

        let formattedNumber = formatter.string(from: NSNumber(value: absValue)) ?? "0"
        return value < 0 ? "-\(formattedNumber)" : formattedNumber
    }

    private func formatCompactAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
