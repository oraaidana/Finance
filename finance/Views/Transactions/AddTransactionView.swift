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

    init(transactionToEdit: Transaction? = nil, onSave: @escaping (Transaction) -> Void, onDelete: ((Transaction) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(transactionToEdit: transactionToEdit))
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Dark background
                Color.black.opacity(animateIn ? 0.5 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if isNoteFieldFocused {
                            isNoteFieldFocused = false
                        } else {
                            dismissSheet()
                        }
                    }

                // Bottom sheet
                VStack(spacing: 0) {
                    dragIndicator
                    sheetContent
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(Color.appBackground)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .offset(y: animateIn ? dragOffset : geometry.size.height)
                .gesture(dragGesture)
                .onTapGesture {
                    isNoteFieldFocused = false
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                animateIn = true
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
            cardSelectorSection
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
        .padding(.bottom, 16)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 8) {
            TransactionTypeToggle(selectedMode: $viewModel.transactionMode)

            Spacer()

            // Date button
            Button(action: { viewModel.showDatePicker = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(viewModel.dateDisplayText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.appTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.appCardBackground)
                .cornerRadius(16)
            }
            .buttonStyle(.plain)

            // Settings button
            Button(action: { viewModel.showCategoryManager = true }) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(.appTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.appCardBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Amount Display
    private var amountDisplaySection: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(viewModel.currencySymbol)
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.appTextSecondary)

            Text(viewModel.formattedAmount)
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Card Selector
    private var cardSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.getCards()) { card in
                    CardPill(card: card, isSelected: viewModel.selectedCard?.id == card.id)
                        .onTapGesture { viewModel.selectedCard = card }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Note Field
    private var noteFieldSection: some View {
        HStack {
            Image(systemName: "pencil")
                .foregroundColor(.appTextSecondary)

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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.getVisibleCategories()) { category in
                    CategoryPill(category: category, isSelected: viewModel.selectedCategory?.id == category.id)
                        .onTapGesture {
                            viewModel.selectedCategory = category
                            isNoteFieldFocused = false
                        }
                }
            }
            .padding(.horizontal, 4)
        }
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
