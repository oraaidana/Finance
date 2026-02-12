import SwiftUI
import Combine

// Note: PeriodType is now defined in core/domain/models/TimePeriod.swift

@MainActor
class HomeViewModel: ObservableObject {
    // Dependencies
    private let dataManager: SharedDataManager
    private let cardManager: CardManager
    private let categoryManager: CategoryManager

    // State
    @Published var searchText: String = ""
    @Published var selectedCardIndex: Int = 0
    @Published private(set) var filteredTransactions: [Transaction] = []

    // Period State
    @Published var selectedPeriod: PeriodType = .day
    @Published var periodOffset: Int = 0
    @Published var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var customEndDate: Date = Date()

    // UI State
    @Published var showingAddTransaction = false
    @Published var showingImportStatement = false
    @Published var transactionToEdit: Transaction? = nil

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var totalBalance: Double {
        cardManager.cards.reduce(0) { $0 + $1.balance }
    }

    var cards: [Card] {
        cardManager.cards
    }

    var hasCards: Bool {
        !cardManager.cards.isEmpty
    }

    var selectedCard: Card? {
        cardManager.cards[safe: selectedCardIndex]
    }

    var totalIncome: Double {
        dataManager.totalIncome
    }

    var totalExpenses: Double {
        dataManager.totalExpenses
    }

    var categorySpending: [CategorySpending] {
        dataManager.categorySpending
    }

    var transactionCount: Int {
        filteredTransactions.count
    }

    // MARK: - Period Calculations

    var periodDateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()

        switch selectedPeriod {
        case .day:
            let targetDate = calendar.date(byAdding: .day, value: periodOffset, to: today) ?? today
            let startOfDay = calendar.startOfDay(for: targetDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            return (startOfDay, endOfDay)

        case .week:
            let targetDate = calendar.date(byAdding: .weekOfYear, value: periodOffset, to: today) ?? today
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate)) ?? targetDate
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            return (weekStart, weekEnd)

        case .month:
            let targetDate = calendar.date(byAdding: .month, value: periodOffset, to: today) ?? today
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate)) ?? targetDate
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            return (monthStart, monthEnd)

        case .year:
            let targetDate = calendar.date(byAdding: .year, value: periodOffset, to: today) ?? today
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: targetDate)) ?? targetDate
            let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart) ?? yearStart
            return (yearStart, yearEnd)

        case .last7Days:
            let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today)) ?? today
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today)) ?? today
            return (start, end)

        case .last30Days:
            let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: today)) ?? today
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today)) ?? today
            return (start, end)

        case .allTime:
            let distantPast = Date.distantPast
            let distantFuture = Date.distantFuture
            return (distantPast, distantFuture)

        case .custom:
            let start = calendar.startOfDay(for: customStartDate)
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEndDate)) ?? customEndDate
            return (start, end)
        }
    }

    var periodTransactions: [Transaction] {
        let range = periodDateRange
        var result = dataManager.transactions.filter { transaction in
            transaction.date >= range.start && transaction.date < range.end
        }

        // Filter by selected card if applicable
        if let selectedCard = cardManager.cards[safe: selectedCardIndex] {
            result = result.filter { $0.cardId == selectedCard.id || $0.cardId == nil }
        }

        return result
    }

    var periodIncome: Double {
        periodTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var periodExpenses: Double {
        periodTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var periodBalance: Double {
        periodIncome - periodExpenses
    }

    // MARK: - Grouped Transactions by Date

    struct TransactionGroup: Identifiable {
        let id = UUID()
        let date: Date
        let transactions: [Transaction]

        var dateDisplayText: String {
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")

            if calendar.isDateInToday(date) {
                formatter.dateFormat = "EE, d MMMM"
                return "\(formatter.string(from: date).capitalized) - Сегодня"
            } else if calendar.isDateInYesterday(date) {
                formatter.dateFormat = "EE, d MMMM"
                return "\(formatter.string(from: date).capitalized) - Вчера"
            } else {
                formatter.dateFormat = "EE, d MMMM"
                return formatter.string(from: date).capitalized
            }
        }
    }

    var groupedPeriodTransactions: [TransactionGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: periodTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        return grouped.map { date, transactions in
            TransactionGroup(date: date, transactions: transactions.sorted { $0.date > $1.date })
        }
        .sorted { $0.date > $1.date }
    }

    var periodDisplayText: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")

        switch selectedPeriod {
        case .day:
            let targetDate = calendar.date(byAdding: .day, value: periodOffset, to: Date()) ?? Date()
            if calendar.isDateInToday(targetDate) {
                return "Сегодня"
            } else if calendar.isDateInYesterday(targetDate) {
                return "Вчера"
            } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
                      calendar.isDate(targetDate, inSameDayAs: tomorrow) {
                return "Завтра"
            } else {
                formatter.dateFormat = "d MMM"
                return formatter.string(from: targetDate)
            }

        case .week:
            let range = periodDateRange
            formatter.dateFormat = "d MMM"
            let startStr = formatter.string(from: range.start)
            let endDate = calendar.date(byAdding: .day, value: -1, to: range.end) ?? range.end
            let endStr = formatter.string(from: endDate)
            return "\(startStr) - \(endStr)"

        case .month:
            let targetDate = calendar.date(byAdding: .month, value: periodOffset, to: Date()) ?? Date()
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: targetDate).capitalized

        case .year:
            let targetDate = calendar.date(byAdding: .year, value: periodOffset, to: Date()) ?? Date()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: targetDate)

        case .last7Days:
            return "Последние 7 дней"

        case .last30Days:
            return "Последние 30 дней"

        case .allTime:
            return "Все время"

        case .custom:
            formatter.dateFormat = "d MMM"
            let startStr = formatter.string(from: customStartDate)
            let endStr = formatter.string(from: customEndDate)
            return "\(startStr) - \(endStr)"
        }
    }

    // MARK: - Period Navigation

    func movePeriodBackward() {
        guard selectedPeriod.canNavigate else { return }
        periodOffset -= 1
    }

    func movePeriodForward() {
        guard selectedPeriod.canNavigate else { return }
        periodOffset += 1
    }

    func resetPeriodOffset() {
        periodOffset = 0
    }

    // MARK: - Initialization

    init(
        dataManager: SharedDataManager,
        cardManager: CardManager = .shared,
        categoryManager: CategoryManager = .shared
    ) {
        self.dataManager = dataManager
        self.cardManager = cardManager
        self.categoryManager = categoryManager

        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest3(
            dataManager.$transactions,
            $searchText,
            $selectedCardIndex
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] transactions, searchText, cardIndex in
            self?.updateFilteredTransactions(
                transactions: transactions,
                searchText: searchText,
                cardIndex: cardIndex
            )
        }
        .store(in: &cancellables)
    }

    private func updateFilteredTransactions(
        transactions: [Transaction],
        searchText: String,
        cardIndex: Int
    ) {
        var result = transactions

        // Filter by selected card
        if let selectedCard = cardManager.cards[safe: cardIndex] {
            result = result.filter { $0.cardId == selectedCard.id || $0.cardId == nil }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredTransactions = result
    }

    // MARK: - Actions

    func addTransaction(_ transaction: Transaction) {
        dataManager.addTransaction(transaction)
    }

    func updateTransaction(_ transaction: Transaction) {
        dataManager.updateTransaction(transaction)
    }

    func deleteTransaction(_ transaction: Transaction) {
        dataManager.deleteTransaction(transaction)
    }

    func addCard(_ card: Card) {
        cardManager.addCard(card)
    }

    func clearSearch() {
        searchText = ""
    }

    func getCategoryManager() -> CategoryManager {
        categoryManager
    }

    // MARK: - Formatting

    func formatCurrency(_ value: Double) -> String {
        CurrencyFormatter.shared.format(value, currency: .kzt)
    }
}
