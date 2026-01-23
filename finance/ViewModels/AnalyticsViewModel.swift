import SwiftUI
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    // Dependencies
    private let dataManager: SharedDataManager

    // State
    @Published var selectedPeriod: TimePeriod = .month
    @Published private(set) var periodTransactions: [Transaction] = []
    @Published private(set) var periodIncome: Double = 0
    @Published private(set) var periodExpenses: Double = 0
    @Published private(set) var periodCategorySpending: [CategorySpending] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var incomeBarHeight: CGFloat {
        let maxValue = max(periodIncome, periodExpenses)
        guard maxValue > 0 else { return 20 }
        return CGFloat(periodIncome / maxValue) * 120
    }

    var expensesBarHeight: CGFloat {
        let maxValue = max(periodIncome, periodExpenses)
        guard maxValue > 0 else { return 20 }
        return CGFloat(periodExpenses / maxValue) * 120
    }

    var netBalance: Double {
        periodIncome - periodExpenses
    }

    var transactionCount: Int {
        periodTransactions.count
    }

    // MARK: - Initialization

    init(dataManager: SharedDataManager) {
        self.dataManager = dataManager
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest(
            dataManager.$transactions,
            $selectedPeriod
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] transactions, period in
            self?.updatePeriodData(transactions: transactions, period: period)
        }
        .store(in: &cancellables)
    }

    // MARK: - Period Data Update

    private func updatePeriodData(transactions: [Transaction], period: TimePeriod) {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -period.days,
            to: Date()
        ) ?? Date()

        periodTransactions = transactions.filter { $0.date >= cutoffDate }

        periodIncome = periodTransactions
            .filter { !$0.isExpense }
            .reduce(0) { $0 + $1.amount }

        periodExpenses = periodTransactions
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.amount }

        periodCategorySpending = calculateCategorySpending(for: periodTransactions)
    }

    private func calculateCategorySpending(for transactions: [Transaction]) -> [CategorySpending] {
        let expenseTransactions = transactions.filter { $0.isExpense }
        let total = expenseTransactions.reduce(0) { $0 + $1.amount }

        var categoryAmounts: [TransactionCategory2: Double] = [:]

        for transaction in expenseTransactions {
            let category = categoryFromString(transaction.category)
            categoryAmounts[category, default: 0] += transaction.amount
        }

        return categoryAmounts.map { category, amount in
            let percentage = total > 0 ? amount / total : 0
            return CategorySpending(category: category, amount: amount, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }

    private func categoryFromString(_ categoryString: String) -> TransactionCategory2 {
        switch categoryString.lowercased() {
        case "shopping": return .shopping
        case "health": return .health
        case "transport": return .transport
        case "housing": return .housing
        case "subscriptions": return .subscriptions
        case "food": return .shopping
        case "entertainment": return .shopping
        case "utilities": return .housing
        case "transfer": return .transport
        default: return .shopping
        }
    }

    // MARK: - Formatting

    func formatCurrency(_ value: Double) -> String {
        CurrencyFormatter.shared.format(value, currency: .kzt)
    }
}
