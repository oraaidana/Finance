//
//  BankStatementUploadView.swift
//  finance
//
//  Created by Claude on 01/23/26.
//  Redesigned on 01/29/26 with enhanced transaction display
//

import SwiftUI
import UniformTypeIdentifiers

struct BankStatementUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: SharedDataManager

    @State private var parsedTransactions: [ParsedTransaction] = []
    @State private var isShowingFilePicker = false
    @State private var isLoading = false
    @State private var loadingMessage = "Connecting to server..."
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false
    @State private var importedCount = 0
    @State private var detectedBank: String?
    @State private var selectedFilter: String = "All"

    private var selectedCount: Int {
        parsedTransactions.filter { $0.isSelected }.count
    }

    private var filteredTransactions: [ParsedTransaction] {
        if selectedFilter == "All" {
            return parsedTransactions
        }
        return parsedTransactions.filter { $0.category == selectedFilter }
    }

    private var categorySummary: [(String, Int, Color)] {
        var counts: [String: Int] = [:]
        for tx in parsedTransactions {
            counts[tx.category, default: 0] += 1
        }
        return counts.map { (key, value) in
            (key, value, categoryColor(for: key))
        }.sorted { $0.1 > $1.1 }
    }

    private var totalAmount: Double {
        parsedTransactions.reduce(0) { $0 + ($1.isExpense ? -$1.amount : $1.amount) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if parsedTransactions.isEmpty {
                    uploadPromptView
                } else {
                    reviewTransactionsView
                }

                if isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("Import Statement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !parsedTransactions.isEmpty {
                        Button("Reset") {
                            withAnimation {
                                parsedTransactions = []
                                detectedBank = nil
                                selectedFilter = "All"
                            }
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundColor(.appTextSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color.appCardBackground)
                            .clipShape(Circle())
                    }
                }
            }
            .fileImporter(
                isPresented: $isShowingFilePicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("Done") { dismiss() }
            } message: {
                Text("Successfully imported \(importedCount) transactions")
            }
        }
    }

    // MARK: - Upload Prompt View
    private var uploadPromptView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
            }

            // Title
            Text("Import Bank Statement")
                .font(.title2)
                .fontWeight(.bold)

            // Description
            Text("Upload your bank statement PDF and our AI will automatically categorize your transactions.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // AI Badge
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.caption)
                Text("AI-Powered Classification")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.purple)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)

            // Supported banks
            VStack(spacing: 8) {
                Text("Supported Banks")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)

                HStack(spacing: 12) {
                    BankBadge(name: "Kaspi", color: .red)
                    BankBadge(name: "Freedom", color: .blue)
                    BankBadge(name: "Halyk", color: .green)
                    BankBadge(name: "Jusan", color: .orange)
                }
            }
            .padding(.top, 16)

            Spacer()

            // Upload Button
            Button(action: { isShowingFilePicker = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Select PDF File")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appPrimary)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Review Transactions View
    private var reviewTransactionsView: some View {
        VStack(spacing: 0) {
            // Summary Card
            summaryCard
                .padding(.horizontal, 20)
                .padding(.top, 16)

            // Category Filter
            categoryFilterView
                .padding(.top, 16)

            // Selection Controls
            HStack {
                Button(action: selectAll) {
                    Text("Select All")
                        .font(.caption)
                        .foregroundColor(.appPrimary)
                }

                Spacer()

                Text("\(selectedCount) of \(filteredTransactions.count) selected")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)

                Spacer()

                Button(action: deselectAll) {
                    Text("Deselect All")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Transactions List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredTransactions.indices, id: \.self) { index in
                        if let actualIndex = parsedTransactions.firstIndex(where: { $0.id == filteredTransactions[index].id }) {
                            ImportTransactionRow(
                                transaction: $parsedTransactions[actualIndex]
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }

            // Import Button
            VStack(spacing: 8) {
                Button(action: importSelectedTransactions) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Import \(selectedCount) Transactions")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedCount > 0 ? Color.appIncome : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(selectedCount == 0)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(Color.appBackground)
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 16) {
            // Bank Header
            HStack {
                if let bank = detectedBank {
                    HStack(spacing: 8) {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(bankColor(for: bank))
                        Text(bank)
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(parsedTransactions.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)
                    Text("transactions")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Divider()

            // Category Breakdown
            VStack(spacing: 8) {
                ForEach(categorySummary.prefix(4), id: \.0) { category, count, color in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)

                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.appTextPrimary)

                        Spacer()

                        Text("\(count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appTextSecondary)

                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.appBorder)
                                    .frame(height: 4)
                                    .cornerRadius(2)

                                Rectangle()
                                    .fill(color)
                                    .frame(width: geo.size.width * CGFloat(count) / CGFloat(parsedTransactions.count), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(width: 60, height: 4)
                    }
                }

                if categorySummary.count > 4 {
                    Text("+\(categorySummary.count - 4) more categories")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }

    // MARK: - Category Filter
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", count: parsedTransactions.count, isSelected: selectedFilter == "All") {
                    selectedFilter = "All"
                }

                ForEach(categorySummary, id: \.0) { category, count, color in
                    FilterChip(title: category, count: count, color: color, isSelected: selectedFilter == category) {
                        selectedFilter = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Animated icon
                ZStack {
                    Circle()
                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)

                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.appPrimary)
                }

                Text(loadingMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextPrimary)

                Text("AI is analyzing your transactions")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            .padding(32)
            .background(Color.appCardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20)
        }
    }

    // MARK: - Actions
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            parseFile(at: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func parseFile(at url: URL) {
        isLoading = true
        loadingMessage = "Uploading file..."

        Task {
            do {
                await MainActor.run {
                    loadingMessage = "AI is categorizing transactions..."
                }

                let transactions = try await StatementParserService.shared.parseFile(at: url)

                await MainActor.run {
                    parsedTransactions = transactions
                    detectedBank = transactions.first?.bank
                    isLoading = false

                    if transactions.isEmpty {
                        errorMessage = "No transactions found in the file."
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }

    private func selectAll() {
        for i in parsedTransactions.indices {
            if selectedFilter == "All" || parsedTransactions[i].category == selectedFilter {
                parsedTransactions[i].isSelected = true
            }
        }
    }

    private func deselectAll() {
        for i in parsedTransactions.indices {
            if selectedFilter == "All" || parsedTransactions[i].category == selectedFilter {
                parsedTransactions[i].isSelected = false
            }
        }
    }

    private func importSelectedTransactions() {
        let selected = parsedTransactions.filter { $0.isSelected }

        for parsed in selected {
            let transactionType: TransactionType = {
                switch parsed.category.lowercased() {
                case "subscriptions": return .subscriptions
                case "shopping", "groceries": return .shopping
                case "food": return .food
                case "entertainment": return .entertainment
                case "bills", "utilities": return .utilities
                case "transfer": return .transfer
                default: return .other
                }
            }()

            let transaction = Transaction(
                title: parsed.title,
                amount: parsed.amount,
                category: parsed.category,
                date: parsed.date,
                type: transactionType,
                isExpense: parsed.isExpense,
                cardId: CardManager.shared.selectedCard?.id
            )

            dataManager.addTransaction(transaction)
        }

        importedCount = selected.count
        showSuccess = true
    }

    // MARK: - Helpers
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "food": return .orange
        case "groceries": return .green
        case "transport": return .blue
        case "shopping": return .pink
        case "subscriptions": return .purple
        case "transfer": return .cyan
        case "entertainment": return .yellow
        case "health": return .red
        default: return .gray
        }
    }

    private func bankColor(for bank: String) -> Color {
        if bank.lowercased().contains("kaspi") { return .red }
        if bank.lowercased().contains("freedom") { return .blue }
        if bank.lowercased().contains("halyk") { return .green }
        if bank.lowercased().contains("jusan") { return .orange }
        return .gray
    }
}

#Preview {
    BankStatementUploadView()
        .environmentObject(SharedDataManager())
}
