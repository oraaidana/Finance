// BudgetView.swift

import SwiftUI
import Charts

struct BudgetView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var showAddBudget = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Budget").font(.system(size: 26, weight: .black, design: .rounded)).foregroundColor(AppTheme.textPrimary)
                        Text("Stay on track with spending limits").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    Button(action: { showAddBudget = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                            .padding(10).background(AppTheme.accentSoft)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PressEffect())
                }
                .padding(.horizontal, 20).padding(.top, 16)

                // Budget vs Actual Bar Chart
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Budget vs Actual").font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text("Monthly spending by category").font(.system(size: 12)).foregroundColor(AppTheme.textMuted)
                    }

                    // Legend
                    HStack(spacing: 16) {
                        legendItem(color: AppTheme.accent.opacity(0.3), label: "Budget")
                        legendItem(color: AppTheme.accent, label: "Spent")
                    }

                    Chart {
                        ForEach(dataManager.budgets) { budget in
                            let spent = dataManager.spent(for: budget.category)
                            BarMark(x: .value("Category", budget.category.rawValue),
                                    y: .value("Budget", budget.limit))
                                .foregroundStyle(AppTheme.surface2)
                                .cornerRadius(6)
                            BarMark(x: .value("Category", budget.category.rawValue),
                                    y: .value("Spent", min(spent, budget.limit)))
                                .foregroundStyle(budgetColor(spent: spent, limit: budget.limit))
                                .cornerRadius(6)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted).font(.system(size: 9)) }
                    }
                    .chartYAxis {
                        AxisMarks { AxisValueLabel().foregroundStyle(AppTheme.textMuted).font(.system(size: 10)) }
                    }
                    .frame(height: 160)
                }
                .glassCard()
                .padding(.horizontal, 20)

                // Summary Cards
                // Summary Cards
                let totalBudget = dataManager.budgets.reduce(0.0) { sum, budget in
                    sum + budget.limit
                }

                let totalSpent = dataManager.budgets.reduce(0.0) { sum, budget in
                    sum + dataManager.spent(for: budget.category)
                }

                let remaining = totalBudget - totalSpent

                HStack(spacing: 12) {
                    BudgetSummaryChip(label: "Budget", value: totalBudget, color: AppTheme.accent)
                    BudgetSummaryChip(label: "Spent",  value: totalSpent,  color: AppTheme.red)
                    BudgetSummaryChip(label: "Left",   value: remaining,   color: remaining >= 0 ? AppTheme.green : AppTheme.red)
                }
                .padding(.horizontal, 20)

                // Budget Cards Grid
                Text("Categories")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(dataManager.budgets) { budget in
                        BudgetCard(budget: budget, spent: dataManager.spent(for: budget.category))
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 100)
            }
        }
        .background(AppTheme.bg)
        .sheet(isPresented: $showAddBudget) {
            AddBudgetSheet()
                .environmentObject(dataManager) // Explicitly pass it to the sheet
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(label).font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
        }
    }

    private func budgetColor(spent: Double, limit: Double) -> Color {
        let pct = spent / limit
        if pct >= 1.0 { return AppTheme.red }
        if pct >= 0.8 { return AppTheme.yellow }
        return AppTheme.accent
    }
}

// MARK: - Budget Card
struct BudgetCard: View {
    let budget: Budget
    let spent: Double

    var pct: Double { min(spent / budget.limit, 1.0) }
    var remaining: Double { max(budget.limit - spent, 0) }
    var progressColor: Color {
        if pct >= 1.0 { return AppTheme.red }
        if pct >= 0.8 { return AppTheme.yellow }
        return budget.category.color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(budget.category.softColor).frame(width: 38, height: 38)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 15)).foregroundColor(budget.category.color)
                }
                Spacer()
                Text("\(Int(pct * 100))%")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(progressColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(budget.category.rawValue)
                    .font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                Text("$\(String(format: "%.0f", remaining)) left")
                    .font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(AppTheme.surface2).frame(height: 6)
                    RoundedRectangle(cornerRadius: 3).fill(progressColor)
                        .frame(width: geo.size.width * CGFloat(pct), height: 6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: pct)
                }
            }
            .frame(height: 6)

            HStack {
                Text("$\(String(format: "%.0f", spent))")
                    .font(.system(size: 11, weight: .semibold)).foregroundColor(progressColor)
                Text("/ $\(String(format: "%.0f", budget.limit))")
                    .font(.system(size: 11)).foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
    }
}

struct BudgetSummaryChip: View {
    let label: String; let value: Double; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text("$\(String(format: "%.0f", abs(value)))")
                .font(.system(size: 16, weight: .black, design: .rounded)).foregroundColor(color)
            Text(label).font(.system(size: 10, weight: .medium)).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
    }
}

// MARK: - Add Budget Sheet
struct AddBudgetSheet: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var category: TransactionCategory = .food
    @State private var limitStr = ""

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 22) {
                RoundedRectangle(cornerRadius: 3).fill(AppTheme.surface2).frame(width: 36, height: 4).padding(.top, 12)
                HStack {
                    Text("Set Budget").font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted).padding(8).background(AppTheme.surface2).clipShape(Circle())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Category", systemImage: "tag.fill").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                    Picker("", selection: $category) {
                        ForEach(TransactionCategory.allCases.filter { !$0.isIncomeCategory }, id: \.self) { c in
                            HStack { Image(systemName: c.icon); Text(c.rawValue) }.tag(c)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .background(AppTheme.surface).clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Monthly Limit", systemImage: "dollarsign.circle.fill").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                    AuthField(icon: "dollarsign", placeholder: "e.g. 500", text: $limitStr, isSecure: false)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    guard let l = Double(limitStr), l > 0 else { return }
                    dataManager.addBudget(Budget(category: category, limit: l))
                    dismiss()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.radiusMD).fill(AppTheme.accentGradient)
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 4)
                        Text("Save Budget").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    }.frame(height: 54)
                }
                .buttonStyle(PressEffect())
                .disabled(Double(limitStr) == nil)
                .opacity(Double(limitStr) == nil ? 0.5 : 1)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
