import SwiftUI
import Combine

@MainActor
class AddTransactionViewModel: ObservableObject {
    // Dependencies
    private let cardManager: CardManager
    private let categoryManager: CategoryManager

    // Edit mode
    let transactionToEdit: Transaction?
    var isEditMode: Bool { transactionToEdit != nil }

    // Form state
    @Published var amountString: String = "0"
    @Published var transactionMode: TransactionMode = .expense
    @Published var selectedCard: Card?
    @Published var selectedCategory: SpendingCategory?
    @Published var note: String = ""
    @Published var selectedDate: Date = Date()
    @Published var hasPickedDate: Bool = false

    // UI state
    @Published var showDatePicker = false
    @Published var showCategoryManager = false
    @Published var showImportSheet = false
    @Published var showDeleteConfirmation = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var formattedAmount: String {
        if amountString == "0" { return "0" }

        if amountString.contains(".") {
            let parts = amountString.split(separator: ".")
            if let intPart = Int(parts[0]) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = ","
                let formattedInt = formatter.string(from: NSNumber(value: intPart)) ?? String(intPart)
                return parts.count > 1 ? "\(formattedInt).\(parts[1])" : "\(formattedInt)."
            }
        }

        if let intValue = Int(amountString) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            return formatter.string(from: NSNumber(value: intValue)) ?? amountString
        }

        return amountString
    }

    var canSave: Bool {
        guard let amountValue = Double(amountString), amountValue > 0 else { return false }
        guard selectedCard != nil else { return false }
        return selectedCategory != nil
    }

    var dateDisplayText: String {
        if !hasPickedDate && selectedDate.isToday {
            return "Today"
        }
        return selectedDate.formatted(date: .abbreviated, time: .omitted)
    }

    var currencySymbol: String {
        selectedCard?.currencySymbol ?? "₸"
    }

    // MARK: - Initialization

    init(
        transactionToEdit: Transaction? = nil,
        cardManager: CardManager = .shared,
        categoryManager: CategoryManager = .shared
    ) {
        self.transactionToEdit = transactionToEdit
        self.cardManager = cardManager
        self.categoryManager = categoryManager

        setupInitialState()
        setupBindings()
    }

    private func setupBindings() {
        $transactionMode
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self, !self.isEditMode else { return }
                self.updateSelectedCategory()
            }
            .store(in: &cancellables)
    }

    private func setupInitialState() {
        if let transaction = transactionToEdit {
            amountString = formatAmountForEditing(transaction.amount)
            transactionMode = transaction.isExpense ? .expense : .income
            note = transaction.title == transaction.category ? "" : transaction.title
            selectedDate = transaction.date
            hasPickedDate = !transaction.date.isToday

            if let cardId = transaction.cardId {
                selectedCard = cardManager.cards.first { $0.id == cardId }
            }
            selectedCard = selectedCard ?? cardManager.cards.first

            let categories = categoryManager.visibleCategories(for: transactionMode.categoryType)
            selectedCategory = categories.first { $0.name.lowercased() == transaction.category.lowercased() }
            if selectedCategory == nil {
                selectedCategory = categories.first
            }
        } else {
            selectedCard = cardManager.selectedCard ?? cardManager.cards.first
            updateSelectedCategory()
        }
    }

    // MARK: - Numpad Actions

    func appendDigit(_ digit: String) {
        if digit == "00" {
            guard amountString != "0" && amountString.count < 11 else { return }
            if amountString.contains(".") {
                let parts = amountString.split(separator: ".")
                if parts.count > 1 {
                    if parts[1].count == 1 { amountString += "0" }
                    return
                }
            }
            amountString += "00"
            return
        }

        if amountString == "0" {
            amountString = digit
        } else if amountString.count < 12 {
            if amountString.contains(".") {
                let parts = amountString.split(separator: ".")
                if parts.count > 1 && parts[1].count >= 2 { return }
            }
            amountString += digit
        }
    }

    func appendDecimal() {
        if !amountString.contains(".") {
            amountString += "."
        }
    }

    func deleteLastDigit() {
        amountString = amountString.count > 1 ? String(amountString.dropLast()) : "0"
    }

    // MARK: - Category Management

    func updateSelectedCategory() {
        let categories = categoryManager.visibleCategories(for: transactionMode.categoryType)
        if selectedCategory == nil || selectedCategory?.categoryType != transactionMode.categoryType {
            selectedCategory = categories.first
        }
    }

    func getVisibleCategories() -> [SpendingCategory] {
        categoryManager.visibleCategories(for: transactionMode.categoryType)
    }

    func getCards() -> [Card] {
        cardManager.cards
    }

    // MARK: - Transaction Building

    func buildTransaction() -> Transaction? {
        guard let amountValue = Double(amountString),
              let card = selectedCard,
              let category = selectedCategory else { return nil }

        let isExpense = transactionMode == .expense
        let transactionType = determineTransactionType(category: category)

        return Transaction(
            id: transactionToEdit?.id ?? UUID(),
            title: note.isEmpty ? category.name : note,
            amount: amountValue,
            category: category.name,
            date: selectedDate,
            type: transactionType,
            isExpense: isExpense,
            cardId: card.id
        )
    }

    func handleBalanceUpdates(for transaction: Transaction) {
        // Reverse old balance if editing
        if let oldTransaction = transactionToEdit {
            cardManager.updateBalance(
                for: oldTransaction.cardId ?? transaction.cardId!,
                amount: oldTransaction.amount,
                isExpense: !oldTransaction.isExpense
            )
        }

        // Apply new balance
        cardManager.updateBalance(
            for: transaction.cardId!,
            amount: transaction.amount,
            isExpense: transaction.isExpense
        )
    }

    // MARK: - Private Helpers

    private func formatAmountForEditing(_ amount: Double) -> String {
        if amount == floor(amount) {
            return String(Int(amount))
        }
        return String(format: "%.2f", amount)
            .replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
    }

    private func determineTransactionType(category: SpendingCategory) -> TransactionType {
        switch transactionMode {
        case .income: return .transfer
        case .expense:
            switch category.name.lowercased() {
            case "subscriptions": return .subscriptions
            case "shopping", "groceries": return .shopping
            case "cafe", "food": return .food
            case "entertainment": return .entertainment
            case "utilities", "home": return .utilities
            default: return .other
            }
        }
    }
}
