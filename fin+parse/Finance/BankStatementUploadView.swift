// BankStatementUploadView.swift
// Upload a bank-statement PDF → AI parses it → review & import transactions

import SwiftUI
import UniformTypeIdentifiers

struct BankStatementUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: SharedDataManager

    @State private var parsed: [ParsedTransaction] = []
    @State private var isLoading  = false
    @State private var loadingMsg = "Uploading…"
    @State private var showPicker = false
    @State private var errorMsg: String?
    @State private var showError  = false
    @State private var showSuccess = false
    @State private var importedCount = 0
    @State private var detectedBank: String?
    @State private var categoryFilter = "All"

    // MARK: - Derived
    private var selectedCount: Int { parsed.filter(\.isSelected).count }

    private var filtered: [ParsedTransaction] {
        categoryFilter == "All" ? parsed :
        parsed.filter { $0.category.rawValue == categoryFilter }
    }

    private var categoryCounts: [(name: String, count: Int, color: Color)] {
        var map: [String: Int] = [:]
        for t in parsed { map[t.category.rawValue, default: 0] += 1 }
        return map.map { (name: $0.key, count: $0.value, color: categoryColor($0.key)) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                if parsed.isEmpty { emptyView } else { reviewView }
                if isLoading    { loadingOverlay }
            }
            .navigationTitle("Import Statement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !parsed.isEmpty {
                        Button("Reset") {
                            withAnimation { parsed = []; detectedBank = nil; categoryFilter = "All" }
                        }
                        .foregroundColor(AppTheme.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(8)
                            .background(AppTheme.surface2)
                            .clipShape(Circle())
                    }
                }
            }
            .fileImporter(
                isPresented: $showPicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first { loadFile(url) }
                case .failure(let err):
                    errorMsg = err.localizedDescription; showError = true
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: { Text(errorMsg ?? "An error occurred.") }
            .alert("Imported!", isPresented: $showSuccess) {
                Button("Done") { dismiss() }
            } message: { Text("Successfully imported \(importedCount) transaction\(importedCount == 1 ? "" : "s").") }
        }
    }

    // MARK: - Empty / Upload prompt
    private var emptyView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle().fill(AppTheme.accentSoft).frame(width: 110, height: 110)
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.accentGradient)
            }

            VStack(spacing: 10) {
                Text("Import Bank Statement")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Upload your PDF statement and the AI\nwill automatically categorise transactions.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
            }

            // AI badge
            HStack(spacing: 6) {
                Image(systemName: "cpu.fill").font(.caption)
                Text("AI-Powered Classification").font(.caption).fontWeight(.semibold)
            }
            .foregroundColor(AppTheme.accent)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(AppTheme.accentSoft)
            .clipShape(Capsule())

            // Supported banks
            VStack(spacing: 10) {
                Text("Supported Banks").font(.caption).foregroundColor(AppTheme.textMuted)
                HStack(spacing: 10) {
                    BankBadge(name: "Kaspi",    hex: "#E31E24")
                    BankBadge(name: "Halyk",    hex: "#00703C")
                    BankBadge(name: "Freedom",  hex: "#004F9F")
                    BankBadge(name: "Jusan",    hex: "#FF6B00")
                }
            }

            Spacer()

            Button { showPicker = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Select PDF File").fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(PressEffect())
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Review screen
    private var reviewView: some View {
        VStack(spacing: 0) {
            summaryCard.padding(.horizontal, 20).padding(.top, 16)
            categoryFilterStrip.padding(.top, 14)
            selectControls.padding(.horizontal, 20).padding(.vertical, 10)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { tx in
                        if let idx = parsed.firstIndex(where: { $0.id == tx.id }) {
                            ParsedTransactionRow(tx: $parsed[idx])
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }

            importBar
        }
    }

    // MARK: - Summary card
    private var summaryCard: some View {
        VStack(spacing: 14) {
            HStack {
                if let bank = detectedBank {
                    HStack(spacing: 8) {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(AppTheme.accent)
                        Text(bank).font(.headline).foregroundColor(AppTheme.textPrimary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(parsed.count)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("transactions").font(.caption).foregroundColor(AppTheme.textMuted)
                }
            }
            Divider()
            // Category breakdown
            VStack(spacing: 8) {
                ForEach(categoryCounts.prefix(4), id: \.name) { item in
                    HStack(spacing: 8) {
                        Circle().fill(item.color).frame(width: 8, height: 8)
                        Text(item.name).font(.subheadline).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(item.count)").font(.subheadline).fontWeight(.semibold).foregroundColor(AppTheme.textMuted)
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2).fill(AppTheme.surface2).frame(height: 4)
                                RoundedRectangle(cornerRadius: 2).fill(item.color)
                                    .frame(width: g.size.width * CGFloat(item.count) / CGFloat(max(parsed.count, 1)), height: 4)
                            }
                        }.frame(width: 60, height: 4)
                    }
                }
                if categoryCounts.count > 4 {
                    Text("+\(categoryCounts.count - 4) more categories")
                        .font(.caption).foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusLG).stroke(AppTheme.border))
    }

    // MARK: - Category filter strip
    private var categoryFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", count: parsed.count,
                           selected: categoryFilter == "All", color: AppTheme.accent) {
                    categoryFilter = "All"
                }
                ForEach(categoryCounts, id: \.name) { item in
                    FilterChip(label: item.name, count: item.count,
                               selected: categoryFilter == item.name, color: item.color) {
                        categoryFilter = item.name
                    }
                }
            }.padding(.horizontal, 20)
        }
    }

    // MARK: - Select / deselect controls
    private var selectControls: some View {
        HStack {
            Button("Select All")   { setAllSelected(true)  }.font(.caption).foregroundColor(AppTheme.accent)
            Spacer()
            Text("\(selectedCount) of \(filtered.count) selected").font(.caption).foregroundColor(AppTheme.textMuted)
            Spacer()
            Button("Deselect All") { setAllSelected(false) }.font(.caption).foregroundColor(AppTheme.textMuted)
        }
    }

    // MARK: - Import bar
    private var importBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: commitImport) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import \(selectedCount) Transaction\(selectedCount == 1 ? "" : "s")")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedCount > 0 ? AppTheme.greenGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
                .padding(.horizontal, 20)
            }
            .disabled(selectedCount == 0)
            .buttonStyle(PressEffect())
            .padding(.vertical, 14)
            .background(AppTheme.surface)
        }
    }

    // MARK: - Loading overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle().stroke(AppTheme.accent.opacity(0.25), lineWidth: 4).frame(width: 60, height: 60)
                    ProgressView().scaleEffect(1.4).tint(AppTheme.accent)
                }
                Text(loadingMsg).font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.textPrimary)
                Text("AI is analysing your transactions").font(.caption).foregroundColor(AppTheme.textMuted)
            }
            .padding(32)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG))
            .shadow(color: .black.opacity(0.15), radius: 20)
        }
    }

    // MARK: - Actions
    private func loadFile(_ url: URL) {
        isLoading = true; loadingMsg = "Uploading file…"
        Task {
            do {
                await MainActor.run { loadingMsg = "AI is categorising transactions…" }
                let results = try await StatementParserService.shared.parseFile(at: url)
                await MainActor.run {
                    parsed = results
                    detectedBank = results.first?.bankName
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMsg = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }

    private func commitImport() {
        let selected = parsed.filter(\.isSelected)
        for tx in selected { dataManager.addTransaction(tx.toTransaction()) }
        importedCount = selected.count
        showSuccess = true
    }

    private func setAllSelected(_ value: Bool) {
        for i in parsed.indices {
            if categoryFilter == "All" || parsed[i].category.rawValue == categoryFilter {
                parsed[i].isSelected = value
            }
        }
    }

    // MARK: - Helpers
    private func categoryColor(_ name: String) -> Color {
        TransactionCategory.allCases.first { $0.rawValue == name }?.color ?? AppTheme.textMuted
    }
}

// MARK: - ParsedTransactionRow
struct ParsedTransactionRow: View {
    @Binding var tx: ParsedTransaction

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button { tx.isSelected.toggle() } label: {
                Image(systemName: tx.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(tx.isSelected ? AppTheme.accent : AppTheme.textMuted)
            }
            .buttonStyle(PressEffect())

            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(tx.category.softColor).frame(width: 36, height: 36)
                Image(systemName: tx.category.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(tx.category.color)
            }

            // Title + date
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(tx.isSelected ? AppTheme.textPrimary : AppTheme.textMuted)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(tx.formattedDate).font(.system(size: 10)).foregroundColor(AppTheme.textMuted)
                    Text(tx.category.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(tx.category.color)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(tx.category.softColor)
                        .clipShape(Capsule())
                }
            }

            Spacer()

            // Amount
            Text(tx.formattedAmount)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(tx.isExpense ? AppTheme.textPrimary : AppTheme.green)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(tx.isSelected ? AppTheme.surface : AppTheme.bg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMD)
            .stroke(tx.isSelected ? AppTheme.border : Color.clear, lineWidth: 1))
        .animation(.easeInOut(duration: 0.15), value: tx.isSelected)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String; let count: Int; let selected: Bool; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(label).font(.system(size: 12, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.white.opacity(0.7))
                    .clipShape(Capsule())
            }
            .foregroundColor(selected ? .white : AppTheme.textMuted)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(selected ? color : AppTheme.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(selected ? color : AppTheme.border, lineWidth: 1))
        }
        .buttonStyle(PressEffect())
    }
}

// MARK: - Bank Badge
struct BankBadge: View {
    let name: String; let hex: String
    var body: some View {
        Text(name)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color(hex: hex))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Color(hex: hex).opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(hex: hex).opacity(0.3), lineWidth: 1))
    }
}
