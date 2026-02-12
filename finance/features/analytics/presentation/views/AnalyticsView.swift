//
//  AnalyticsView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//
//  Note: AnalyticsTimePeriod is now defined in core/domain/models/TimePeriod.swift

import SwiftUI
import Charts

// Type alias for backward compatibility
typealias TimePeriod = AnalyticsTimePeriod

// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var sharedData: SharedDataManager
    @StateObject private var viewModel: AnalyticsViewModel

    init(viewModel: AnalyticsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AnalyticsViewModel(dataManager: SharedDataManager()))
    }

    var body: some View {
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
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodButton(
                        title: period.rawValue,
                        isSelected: viewModel.selectedPeriod == period
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedPeriod = period
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
                value: viewModel.formatCurrency(viewModel.periodExpenses),
                icon: "arrow.down.circle.fill",
                color: .appExpense
            )

            StatisticCard(
                title: "Total Income",
                value: viewModel.formatCurrency(viewModel.periodIncome),
                icon: "arrow.up.circle.fill",
                color: .appIncome
            )

            StatisticCard(
                title: "Net Balance",
                value: viewModel.formatCurrency(viewModel.netBalance),
                icon: "dollarsign.circle.fill",
                color: .appPrimary
            )

            StatisticCard(
                title: "Transactions",
                value: "\(viewModel.transactionCount)",
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

            if viewModel.periodCategorySpending.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(viewModel.periodCategorySpending, id: \.category) { item in
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
                .background(Color.appCardBackground)
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
                        .fill(Color.appIncome)
                        .frame(width: 60, height: viewModel.incomeBarHeight)
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                // Expenses Bar
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appExpense)
                        .frame(width: 60, height: viewModel.expensesBarHeight)
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appCardBackground)
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
                    color: .appWarning
                )

                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Trend Analysis",
                    description: "Track your financial trends over time.",
                    color: .appPrimary
                )

                InsightCard(
                    icon: "target",
                    title: "Budget Goals",
                    description: "Set and track your budget goals with AI recommendations.",
                    color: .appIncome
                )
            }
        }
    }

    // MARK: - Empty Chart Placeholder
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.appTextSecondary)
            Text("No data available")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Text("Add transactions to see your analytics")
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }

}

#Preview {
    AnalyticsView()
        .environmentObject(SharedDataManager())
}
