// StatementParserService.swift
// Parses bank statement PDFs via a local Python server,
// then maps results onto the app's native Transaction model.

import Foundation
import UniformTypeIdentifiers

// MARK: - API Configuration
struct APIConfig {
    /// Change the non-simulator URL to your Mac's LAN IP when running on a real device.
    #if targetEnvironment(simulator)
    static let baseURL = "http://localhost:5001"
    #else
    static let baseURL = "http://192.168.10.6:5001"
    #endif
}

// MARK: - ParsedTransaction
/// Intermediate model returned by the parser before it is committed to SharedDataManager.
struct ParsedTransaction: Identifiable, Hashable {
    let id = UUID()
    var isSelected: Bool = true

    let date: Date
    let title: String
    let amount: Double
    let isExpense: Bool
    let category: TransactionCategory   // ← app's own enum
    let bankName: String?
    let details: String?

    var formattedAmount: String {
        "\(isExpense ? "-" : "+")₸\(String(format: "%.0f", abs(amount)))"
    }
    var formattedDate: String {
        let f = DateFormatter(); f.dateFormat = "dd.MM.yyyy"; return f.string(from: date)
    }

    /// Convert to the app's native Transaction for persistence.
    func toTransaction() -> Transaction {
        Transaction(title: title, amount: amount, category: category,
                    date: date, isExpense: isExpense)
    }
}

// MARK: - API Wire Types
private struct ClassifyResponse: Codable {
    let bank: String?
    let transactions: [APITransaction]
    let error: String?
}

private struct APITransaction: Codable {
    let date: String?
    let amount: Double?
    let merchant: String?
    let details: String?
    let category: String?
    let bank: String?

    enum CodingKeys: String, CodingKey {
        case date, amount, merchant, details, category, bank
    }
}

// MARK: - Category Mapper (Russian API labels → app enum)
private struct CategoryMapper {
    static func map(_ raw: String?) -> TransactionCategory {
        switch (raw ?? "").lowercased() {
        case "переводы", "transfer":                    return .transfer
        case "покупки", "маркетплейсы", "shopping":    return .shopping
        case "супермаркеты", "groceries":              return .food
        case "рестораны и кафе", "food", "cafe":       return .food
        case "транспорт", "transport":                  return .transport
        case "подписки", "subscriptions":              return .subscriptions
        case "здоровье", "health":                     return .health
        case "развлечения", "entertainment":           return .entertainment
        case "коммунальные", "utilities":              return .utilities
        case "зарплата", "salary":                     return .salary
        case "фриланс", "freelance":                   return .freelance
        case "инвестиции", "investment":               return .investment
        default:                                        return .other
        }
    }
}

// MARK: - Parser Errors
enum ParserError: LocalizedError {
    case unsupportedFormat
    case accessDenied
    case emptyResult
    case serverError(String)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:      return "Only PDF files are supported."
        case .accessDenied:           return "Could not access the selected file."
        case .emptyResult:            return "No transactions found in this statement."
        case .serverError(let m):     return "Server error: \(m)"
        case .networkUnavailable:     return "Could not reach the parser server. Make sure it is running."
        }
    }
}

// MARK: - StatementParserService
final class StatementParserService {
    static let shared = StatementParserService()
    private init() {}

    /// Parse a PDF file and return an array of ParsedTransaction ready for review.
    func parseFile(at url: URL) async throws -> [ParsedTransaction] {
        guard url.pathExtension.lowercased() == "pdf" else {
            throw ParserError.unsupportedFormat
        }
        guard url.startAccessingSecurityScopedResource() else {
            throw ParserError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let data = try Data(contentsOf: url)
        return try await sendToServer(pdfData: data, filename: url.lastPathComponent)
    }

    // MARK: - Private
    private func sendToServer(pdfData: Data, filename: String) async throws -> [ParsedTransaction] {
        guard let serverURL = URL(string: "\(APIConfig.baseURL)/classify") else {
            throw ParserError.serverError("Invalid server URL")
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: application/pdf\r\n\r\n")
        body.append(pdfData)
        body.append("\r\n--\(boundary)--\r\n")
        request.httpBody = body

        let (responseData, urlResponse): (Data, URLResponse)
        do {
            (responseData, urlResponse) = try await URLSession.shared.data(for: request)
        } catch {
            throw ParserError.networkUnavailable
        }

        guard let http = urlResponse as? HTTPURLResponse, http.statusCode == 200 else {
            let code = (urlResponse as? HTTPURLResponse)?.statusCode ?? -1
            throw ParserError.serverError("HTTP \(code)")
        }

        let decoded = try JSONDecoder().decode(ClassifyResponse.self, from: responseData)
        if let err = decoded.error { throw ParserError.serverError(err) }

        let results = decoded.transactions.compactMap { tx -> ParsedTransaction? in
            guard let dateStr = tx.date, let date = parseDate(dateStr), let amount = tx.amount else { return nil }
            let isExpense = amount < 0
            let title = (tx.merchant ?? tx.details ?? "Transaction").trimmingCharacters(in: .whitespaces)
            return ParsedTransaction(
                date: date,
                title: String(title.prefix(80)),
                amount: abs(amount),
                isExpense: isExpense,
                category: CategoryMapper.map(tx.category),
                bankName: tx.bank ?? decoded.bank,
                details: tx.details
            )
        }.sorted { $0.date > $1.date }

        if results.isEmpty { throw ParserError.emptyResult }
        return results
    }

    private func parseDate(_ s: String) -> Date? {
        for fmt in ["yyyy-MM-dd", "dd.MM.yyyy", "dd.MM.yy", "dd/MM/yyyy"] {
            let f = DateFormatter(); f.dateFormat = fmt; f.locale = Locale(identifier: "en_US_POSIX")
            if let d = f.date(from: s) { return d }
        }
        return nil
    }
}

// MARK: - Data helpers
private extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
