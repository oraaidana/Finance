import SwiftUI
import Combine

@MainActor
class BudgetViewModel: ObservableObject {
    // Dependencies
    private let dataManager: SharedDataManager

    // State
    @Published var searchText: String = ""
    @Published private(set) var filteredTransactions: [Transaction] = []

    // UI State
    @Published var showingAddTransaction: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(dataManager: SharedDataManager) {
        self.dataManager = dataManager
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest(
            dataManager.$transactions,
            $searchText
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] transactions, searchText in
            if searchText.isEmpty {
                self?.filteredTransactions = transactions
            } else {
                self?.filteredTransactions = transactions.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - Actions

    func addTransaction(_ transaction: Transaction) {
        dataManager.addTransaction(transaction)
    }

    func clearSearch() {
        searchText = ""
    }

    // MARK: - Category Helpers

    static func iconForCategory(_ type: TransactionType) -> String {
        switch type {
        case .transfer: return "arrow.left.arrow.right"
        case .subscriptions: return "play.tv"
        case .shopping: return "cart"
        case .food: return "fork.knife"
        case .entertainment: return "film"
        case .utilities: return "bolt"
        case .other: return "dollarsign.circle"
        }
    }

    static func colorForCategory(_ type: TransactionType) -> Color {
        switch type {
        case .transfer: return .blue.opacity(0.5)
        case .subscriptions: return .purple.opacity(0.5)
        case .shopping: return .orange.opacity(0.5)
        case .food: return .green.opacity(0.5)
        case .entertainment: return .pink.opacity(0.5)
        case .utilities: return .yellow.opacity(0.5)
        case .other: return .gray.opacity(0.5)
        }
    }
}
