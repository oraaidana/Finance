import SwiftUI
import Combine

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
