//
//  AnalyticsView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//

import SwiftUI
import Charts

// MARK: - Time Period Enum
enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case twoWeeks = "2 Weeks"
    case month = "Month"
    case threeMonths = "3 Months"

    var days: Int {
        switch self {
        case .today: return 1
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var sharedData: SharedDataManager
    @State private var selectedPeriod: TimePeriod = .month

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    periodSelector

                    // Statistics Cards
                    statisticsCards

                    // Spending by Category Chart
                    spendingChart

                    // Income vs Expenses Chart
                    incomeExpensesChart

                    // AI Insights Section
                    aiInsightsSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        title: period.rawValue,
                        isSelected: selectedPeriod == period
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPeriod = period
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Statistics Cards
    private var statisticsCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatisticCard(
                title: "Total Spending",
                value: formatCurrency(sharedData.totalExpenses),
                icon: "arrow.down.circle.fill",
                color: .red
            )

            StatisticCard(
                title: "Total Income",
                value: formatCurrency(sharedData.totalIncome),
                icon: "arrow.up.circle.fill",
                color: .green
            )

            StatisticCard(
                title: "Net Balance",
                value: formatCurrency(sharedData.totalIncome - sharedData.totalExpenses),
                icon: "dollarsign.circle.fill",
                color: .blue
            )

            StatisticCard(
                title: "Transactions",
                value: "\(sharedData.transactions.count)",
                icon: "list.bullet.circle.fill",
                color: .purple
            )
        }
    }

    // MARK: - Spending Chart
    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.horizontal, 4)

            if sharedData.categorySpending.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(sharedData.categorySpending, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", item.category.rawValue))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, spacing: 16)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Income vs Expenses Chart
    private var incomeExpensesChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expenses")
                .font(.headline)
                .padding(.horizontal, 4)

            HStack(spacing: 16) {
                // Income Bar
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                        .frame(width: 60, height: incomeBarHeight)
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Expenses Bar
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 60, height: expensesBarHeight)
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - AI Insights Section
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Insights")
                    .font(.headline)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 12) {
                InsightCard(
                    icon: "lightbulb.fill",
                    title: "Spending Pattern",
                    description: "Your spending analysis will appear here once ML is integrated.",
                    color: .orange
                )

                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Trend Analysis",
                    description: "Track your financial trends over time.",
                    color: .blue
                )

                InsightCard(
                    icon: "target",
                    title: "Budget Goals",
                    description: "Set and track your budget goals with AI recommendations.",
                    color: .green
                )
            }
        }
    }

    // MARK: - Empty Chart Placeholder
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Add transactions to see your analytics")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Helper Properties
    private var incomeBarHeight: CGFloat {
        let maxValue = max(sharedData.totalIncome, sharedData.totalExpenses)
        guard maxValue > 0 else { return 20 }
        return CGFloat(sharedData.totalIncome / maxValue) * 120
    }

    private var expensesBarHeight: CGFloat {
        let maxValue = max(sharedData.totalIncome, sharedData.totalExpenses)
        guard maxValue > 0 else { return 20 }
        return CGFloat(sharedData.totalExpenses / maxValue) * 120
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Period Button
struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

// MARK: - Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(SharedDataManager())
}
