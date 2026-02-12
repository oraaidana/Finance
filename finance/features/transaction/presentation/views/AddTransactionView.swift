//
//  AddTransactionView.swift
//  finance
//
//  Created by Claude on 01/24/26.
//  Redesigned with numpad interface on 01/28/26.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddTransactionViewModel

    // Callbacks
    let onSave: (Transaction) -> Void
    var onDelete: ((Transaction) -> Void)? = nil

    // Focus & Animation (UI-only state stays in View)
    @FocusState private var isNoteFieldFocused: Bool
    @State private var animateIn = false
    @State private var dragOffset: CGFloat = 0
    @State private var showAccountPicker = false
    @State private var localSelectedCardIndex: Int = 0
    @State private var showCategoriesSheet = false

    init(transactionToEdit: Transaction? = nil, onSave: @escaping (Transaction) -> Void, onDelete: ((Transaction) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(transactionToEdit: transactionToEdit))
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                Color.clear
                    .ignoresSafeArea()
                
                // Bottom sheet
                VStack(spacing: 0) {
                    dragIndicator
                    sheetContent
                }
//                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(Color.appBackground)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .offset(y: animateIn ? dragOffset : geometry.size.height)
                .gesture(dragGesture)
                .onTapGesture {
                    isNoteFieldFocused = false
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                //                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                animateIn = true
            }
            // Initialize local card index
            if let selectedCard = viewModel.selectedCard,
               let index = viewModel.getCards().firstIndex(where: { $0.id == selectedCard.id }) {
                localSelectedCardIndex = index
            }
        }
        .sheet(isPresented: $viewModel.showCategoryManager) {
            CategoryManagerView(categoryType: viewModel.transactionMode.categoryType)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.showImportSheet) {
            BankStatementUploadView()
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePickerSheet(selectedDate: $viewModel.selectedDate, hasPickedDate: $viewModel.hasPickedDate)
                .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showAccountPicker) {
            AccountPickerView(
                selectedIndex: $localSelectedCardIndex,
                formatCurrency: { value in
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.minimumFractionDigits = 2
                    formatter.groupingSeparator = " "
                    return "\(formatter.string(from: NSNumber(value: value)) ?? "0") ₸"
                }
            )
            .onDisappear {
                // Update selected card based on local index
                let cards = viewModel.getCards()
                if localSelectedCardIndex < cards.count {
                    viewModel.selectedCard = cards[localSelectedCardIndex]
                }
            }
        }
        .sheet(isPresented: $showCategoriesSheet) {
            CategoriesSheet(
                transactionMode: $viewModel.transactionMode,
                selectedCategory: $viewModel.selectedCategory,
                getCategories: viewModel.getVisibleCategories
            )
        }
        .alert("Delete Transaction", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let transaction = viewModel.transactionToEdit {
                    onDelete?(transaction)
                    dismissSheet()
                }
            }
        } message: {
            Text("Are you sure you want to delete this transaction?")
        }
    }

    // MARK: - Drag Indicator
    private var dragIndicator: some View {
        Capsule()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 150 || value.velocity.height > 500 {
                    dismissSheet()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Sheet Content
    private var sheetContent: some View {
        VStack(spacing: 12) {
            headerSection
            amountDisplaySection
            accountAndDateSection
            noteFieldSection
            categorySelectorSection

            // Numpad
            NumpadView(
                onDigit: { digit in
                    isNoteFieldFocused = false
                    viewModel.appendDigit(digit)
                },
                onDecimal: {
                    isNoteFieldFocused = false
                    viewModel.appendDecimal()
                },
                onDelete: {
                    isNoteFieldFocused = false
                    viewModel.deleteLastDigit()
                },
                onImport: { viewModel.showImportSheet = true },
                onSave: saveTransaction,
                canSave: viewModel.canSave,
                showImport: !viewModel.isEditMode
            )
            .padding(.top, 8)

            // Delete button in edit mode
            if viewModel.isEditMode {
                Button(action: { viewModel.showDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Transaction")
                    }
                    .font(.subheadline)
                    .foregroundColor(.appExpense)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            // Close button
            Button(action: { dismissSheet() }) {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            // Transaction type toggle (center)
            TransactionTypeToggle(selectedMode: $viewModel.transactionMode)

            Spacer()

            // Empty spacer to balance the layout (same width as close button)
            Color.clear
                .frame(width: 40, height: 40)
        }
    }

    // MARK: - Amount Display
    private var amountDisplaySection: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(viewModel.formattedAmount)
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(viewModel.currencySymbol)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.appTextSecondary)

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Account and Date Section
    private var accountAndDateSection: some View {
        HStack {
            // Account selector capsule
            Button(action: { showAccountPicker = true }) {
                HStack(spacing: 8) {
                    // Account icon
                    ZStack {
                        Circle()
                            .fill((viewModel.selectedCard?.color.color ?? .blue).opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: viewModel.selectedCard?.icon ?? "creditcard.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.selectedCard?.color.color ?? .blue)
                    }

                    // Account info
                    VStack(alignment: .leading, spacing: 1) {
                        Text(viewModel.selectedCard?.name ?? "Выбрать счет")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        if let card = viewModel.selectedCard {
                            Text(card.formattedBalance)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.leading, 4)
                .padding(.trailing, 12)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // Date button
            Button(action: { viewModel.showDatePicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Text(viewModel.dateDisplayText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Note Field
    private var noteFieldSection: some View {
        HStack {
            TextField("Add a note...", text: $viewModel.note)
                .foregroundColor(.appTextPrimary)
                .focused($isNoteFieldFocused)

            Spacer()

            if isNoteFieldFocused {
                Button("Done") { isNoteFieldFocused = false }
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }

    // MARK: - Category Selector
    private var categorySelectorSection: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Plus button to open categories sheet
                    Button(action: { showCategoriesSheet = true }) {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            .foregroundColor(.gray.opacity(0.4))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.6))
                            )
                    }
                    .buttonStyle(.plain)

                    // "No category" option
                    CategoryIconButton(
                        emoji: "⊘",
                        color: .gray,
                        isSelected: viewModel.selectedCategory == nil,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedCategory = nil
                            }
                            isNoteFieldFocused = false
                        }
                    )

                    // Category icons
                    ForEach(viewModel.getVisibleCategories()) { category in
                        CategoryIconButton(
                            emoji: category.emoji,
                            color: categoryColor(for: category),
                            isSelected: viewModel.selectedCategory?.id == category.id,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedCategory = category
                                }
                                isNoteFieldFocused = false
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }

            // Selected category name
            Text(viewModel.selectedCategory?.name ?? "Без категории")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    // Helper to get color for category
    private func categoryColor(for category: SpendingCategory) -> Color {
        let colors: [Color] = [
            Color(red: 1.0, green: 0.85, blue: 0.4),  // Yellow
            Color(red: 1.0, green: 0.6, blue: 0.6),   // Pink/Coral
            Color(red: 0.6, green: 0.8, blue: 1.0),   // Light Blue
            Color(red: 0.6, green: 0.9, blue: 0.7),   // Mint
            Color(red: 0.9, green: 0.7, blue: 1.0),   // Lavender
            Color(red: 1.0, green: 0.7, blue: 0.5),   // Peach
            Color(red: 0.7, green: 0.9, blue: 0.9),   // Teal
            Color(red: 0.95, green: 0.8, blue: 0.8),  // Rose
        ]
        let index = abs(category.name.hashValue) % colors.count
        return colors[index]
    }

    // MARK: - Helpers

    private func dismissSheet() {
        isNoteFieldFocused = false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            animateIn = false
            dragOffset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }

    private func saveTransaction() {
        guard let transaction = viewModel.buildTransaction() else { return }
        viewModel.handleBalanceUpdates(for: transaction)
        onSave(transaction)
        dismissSheet()
    }
}

#Preview {
    AddTransactionView { _ in }
}
