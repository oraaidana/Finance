// TransactionsView.swift

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @State private var search     = ""
    @State private var showAdd    = false
    @State private var showImport = false          // ← import sheet
    @State private var filter: FilterType = .all

    enum FilterType: String, CaseIterable {
        case all = "All"; case income = "Income"; case expense = "Expense"
    }

    var filtered: [Transaction] {
        dataManager.transactions.filter { txn in
            let matchSearch = search.isEmpty
                || txn.title.localizedCaseInsensitiveContains(search)
                || txn.category.rawValue.localizedCaseInsensitiveContains(search)
            let matchFilter: Bool = {
                switch filter {
                case .all:     return true
                case .income:  return !txn.isExpense
                case .expense: return txn.isExpense
                }
            }()
            return matchSearch && matchFilter
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── Header ───────────────────────────────────────────
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Transactions")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(dataManager.transactions.count) total entries")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()

                        // Import button
                        Button { showImport = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.doc.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Import")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(AppTheme.accent)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(AppTheme.accentSoft)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(PressEffect())
                    }
                    .padding(.horizontal, 20).padding(.top, 16)

                    // ── Search ───────────────────────────────────────────
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textMuted).font(.system(size: 15))
                        TextField("Search transactions…", text: $search)
                            .foregroundColor(AppTheme.textPrimary)
                            .font(.system(size: 15))
                            .tint(AppTheme.accent)
                        if !search.isEmpty {
                            Button { search = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textMuted).font(.system(size: 15))
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD).stroke(AppTheme.border))
                    .padding(.horizontal, 20)

                    // ── Filter Pills ──────────────────────────────────────
                    HStack(spacing: 8) {
                        ForEach(FilterType.allCases, id: \.self) { f in
                            Button {
                                withAnimation(.spring(response: 0.3)) { filter = f }
                            } label: {
                                Text(f.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(filter == f ? .white : AppTheme.textMuted)
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(filter == f ? AppTheme.accent : AppTheme.surface2)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(PressEffect())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // ── List ─────────────────────────────────────────────
                    if filtered.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40)).foregroundColor(AppTheme.textMuted)
                            Text("No transactions found")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 60)
                    } else {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            let grouped = groupedTransactions
                            ForEach(grouped.keys.sorted(by: >), id: \.self) { date in
                                Section {
                                    VStack(spacing: 0) {
                                        ForEach(grouped[date]!) { txn in
                                            TxnFullRow(transaction: txn)
                                                .padding(.horizontal, 20)
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    Button(role: .destructive) {
                                                        dataManager.deleteTransaction(txn)
                                                    } label: { Label("Delete", systemImage: "trash") }
                                                }
                                            if txn.id != grouped[date]!.last?.id {
                                                Divider()
                                                    .background(AppTheme.border)
                                                    .padding(.horizontal, 20)
                                                    .padding(.leading, 56)
                                            }
                                        }
                                    }
                                    .background(AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                } header: {
                                    Text(sectionHeader(date))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.textMuted)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 24).padding(.vertical, 6)
                                        .background(AppTheme.bg)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
            .background(AppTheme.bg)

            // FAB – add manual transaction
            Button { showAdd = true } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 15, y: 5)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PressEffect())
            .padding(.trailing, 24).padding(.bottom, 100)
        }
        .sheet(isPresented: $showAdd)    { AddTransactionSheet() }
        .sheet(isPresented: $showImport) { BankStatementUploadView() }  // ← import sheet
    }

    // MARK: - Grouping helpers
    private var groupedTransactions: [String: [Transaction]] {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return Dictionary(grouping: filtered) { fmt.string(from: $0.date) }
    }
    private func sectionHeader(_ key: String) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        guard let d = fmt.date(from: key) else { return key }
        let display = DateFormatter(); display.dateFormat = "EEEE, MMM d"
        if Calendar.current.isDateInToday(d)     { return "Today" }
        if Calendar.current.isDateInYesterday(d) { return "Yesterday" }
        return display.string(from: d)
    }
}

// MARK: - Full Transaction Row
struct TxnFullRow: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(transaction.category.softColor).frame(width: 38, height: 38)
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(transaction.category.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(transaction.category.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }
            Spacer()
            Text(transaction.formattedAmount)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(transaction.isExpense ? AppTheme.textPrimary : AppTheme.green)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: - Add Transaction Sheet
struct AddTransactionSheet: View {
    @EnvironmentObject var dataManager: SharedDataManager
    @Environment(\.dismiss) private var dismiss

    @State private var title    = ""
    @State private var amount   = ""
    @State private var isExpense = true
    @State private var category: TransactionCategory = .food
    @State private var date     = Date()
    @State private var note     = ""
    @State private var errorMessage: String?

    var expenseCategories: [TransactionCategory] { TransactionCategory.allCases.filter { !$0.isIncomeCategory } }
    var incomeCategories:  [TransactionCategory] { TransactionCategory.allCases.filter {  $0.isIncomeCategory } }
    var availableCategories: [TransactionCategory] { isExpense ? expenseCategories : incomeCategories }
    var isValid: Bool { !title.isEmpty && Double(amount) != nil && Double(amount)! > 0 }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    RoundedRectangle(cornerRadius: 3).fill(AppTheme.surface2)
                        .frame(width: 36, height: 4).padding(.top, 12)

                    HStack {
                        Text("Add Transaction")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .padding(8).background(AppTheme.surface2).clipShape(Circle())
                        }
                    }

                    // Type Toggle
                    HStack(spacing: 4) {
                        TypeToggleBtn(label: "💸  Expense", active: isExpense, activeColor: AppTheme.red) {
                            withAnimation(.spring(response: 0.3)) { isExpense = true; category = .food }
                        }
                        TypeToggleBtn(label: "💰  Income", active: !isExpense, activeColor: AppTheme.green) {
                            withAnimation(.spring(response: 0.3)) { isExpense = false; category = .salary }
                        }
                    }
                    .padding(4).background(AppTheme.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))

                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Amount", systemImage: "dollarsign.circle.fill")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        HStack {
                            Text("₸")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(isExpense ? AppTheme.red : AppTheme.green)
                            TextField("0", text: $amount)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .keyboardType(.decimalPad)
                                .foregroundColor(AppTheme.textPrimary)
                                .tint(isExpense ? AppTheme.red : AppTheme.green)
                        }
                        .padding(16).background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                            .stroke(isExpense ? AppTheme.red.opacity(0.3) : AppTheme.green.opacity(0.3)))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "text.alignleft")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        AuthField(icon: "pencil", placeholder: "e.g. Magnum Market", text: $title, isSecure: false)
                    }

                    // Category grid
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Category", systemImage: "tag.fill")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(availableCategories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.3)) { category = cat }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: cat.icon).font(.system(size: 18))
                                            .foregroundColor(category == cat ? .white : cat.color)
                                        Text(cat.rawValue).font(.system(size: 10, weight: .medium))
                                            .foregroundColor(category == cat ? .white : AppTheme.textMuted)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(category == cat ? cat.color : AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                                        .stroke(category == cat ? cat.color : AppTheme.border))
                                }
                                .buttonStyle(PressEffect())
                            }
                        }
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Date", systemImage: "calendar")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textMuted)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact).labelsHidden().tint(AppTheme.accent)
                            .padding(14).background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD).stroke(AppTheme.border))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let err = errorMessage {
                        Text(err).font(.system(size: 13)).foregroundColor(AppTheme.red)
                    }

                    Button(action: save) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                                .fill(isValid
                                      ? (isExpense
                                         ? LinearGradient(colors: [AppTheme.red, AppTheme.orange], startPoint: .leading, endPoint: .trailing)
                                         : AppTheme.greenGradient)
                                      : LinearGradient(colors: [AppTheme.surface2], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: isValid ? (isExpense ? AppTheme.red.opacity(0.3) : AppTheme.green.opacity(0.3)) : .clear,
                                        radius: 12, y: 5)
                            Text("Add Transaction")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        }.frame(height: 54)
                    }
                    .buttonStyle(PressEffect()).disabled(!isValid)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func save() {
        guard let amt = Double(amount), amt > 0 else { errorMessage = "Enter a valid amount"; return }
        let txn = Transaction(title: title.isEmpty ? category.rawValue : title,
                              amount: amt, category: category, date: date, isExpense: isExpense, note: note)
        dataManager.addTransaction(txn)
        dismiss()
    }
}

struct TypeToggleBtn: View {
    let label: String; let active: Bool; let activeColor: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(active ? .white : AppTheme.textMuted)
                .frame(maxWidth: .infinity).padding(.vertical, 11)
                .background(active ? activeColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(PressEffect())
    }
}
