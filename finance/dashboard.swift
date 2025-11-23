//
//  DashboardView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Divider()
                        HStack{
                            Text("\(dataManager.transactions.count)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.secondary)
                            Text("Transactions")
                                .font(.system(size: 20, weight: .semibold)).foregroundStyle(Color.secondary)
                        }
                        
                        Text("Finance Assistant")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Divider()
                    }
                    .padding(.top)
                    
                    // Spending by Category Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Spending by Category")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Pie Chart - Only show if there are expenses
                        if dataManager.totalExpenses > 0 {
                            Chart {
                                ForEach(dataManager.categorySpending) { category in
                                    SectorMark(
                                        angle: .value("Spending", category.amount),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(category.category.color)
                                    .annotation(position: .overlay) {
                                        Text("\(Int(category.percentage * 100))%")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(height: 220)
                            .padding(.horizontal)
                        } else {
                            // Placeholder when no expenses
                            Text("No expenses yet")
                                .foregroundColor(.secondary)
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category Details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 0) {
                                ForEach(dataManager.categorySpending) { categorySpending in
                                    CategoryRow(
                                        categorySpending: categorySpending,
                                        isLast: categorySpending.id == dataManager.categorySpending.last?.id
                                    )
                                }
                                
                                // Total Expenses Row
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Total Expenses")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(dataManager.totalExpenses, specifier: "%.2f")")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color(.systemGray4)),
                                    alignment: .top
                                )
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 2)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Quick Overview Cards
                    VStack(spacing: 16) {
                        Text("Quick Overview")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            OverviewCard(title: "This Month", amount: dataManager.thisMonthExpenses, trend: dataManager.monthlyTrend)
                            OverviewCard(title: "Income", amount: dataManager.totalIncome, trend: .up)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationTitle("Dashboard")
            .background(Color(.white))
        }
    }
}

// MARK: - Category Spending Model
struct CategorySpending: Identifiable {
    let id = UUID()
    let category: TransactionCategory2
    let amount: Double
    let percentage: Double
    
    var formattedAmount: String {
        "$\(amount, default: "%.2f")"
    }
    
    var formattedPercentage: String {
        "\(Int(percentage * 100))%"
    }
}

// MARK: - Category Row 
struct CategoryRow: View {
    let categorySpending: CategorySpending
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Category Icon and Name
                HStack(spacing: 12) {
                    Image(systemName: categorySpending.category.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(categorySpending.category.color)
                        .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(categorySpending.category.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(categorySpending.formattedPercentage)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Amount
                Text(categorySpending.formattedAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding()
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.3)
                        .foregroundColor(Color(.systemGray4))
                    
                    Rectangle()
                        .frame(width: min(CGFloat(categorySpending.percentage) * geometry.size.width, geometry.size.width), height: 4)
                        .foregroundColor(categorySpending.category.color)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Separator - only show if not last item
            if !isLast {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4))
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Overview Card
struct OverviewCard: View {
    let title: String
    let amount: Double
    let trend: TrendDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$\(amount, specifier: "%.2f")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(trend == .up ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.white))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}

// MARK: - Trend Direction
enum TrendDirection {
    case up, down
}

// MARK: - TransactionCategory2 (for Dashboard)
enum TransactionCategory2: String, CaseIterable {
    case shopping = "Shopping"
    case health = "Health"
    case transport = "Transport"
    case housing = "Housing"
    case subscriptions = "Subscriptions"
    
    var iconName: String {
        switch self {
        case .shopping: return "cart"
        case .health: return "heart"
        case .transport: return "car"
        case .housing: return "house"
        case .subscriptions: return "play.tv"
        }
    }
    
    var color: Color {
        switch self {
        case .shopping: return .orange
        case .health: return .pink
        case .transport: return .blue
        case .housing: return .green
        case .subscriptions: return .yellow
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(SharedDataManager())
}
