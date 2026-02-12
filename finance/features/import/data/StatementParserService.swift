//
//  StatementParserService.swift
//  finance
//
//  Service for parsing bank statements via API
//

import Foundation
import UniformTypeIdentifiers

// MARK: - API Configuration
struct APIConfig {
    // Change this to your server IP when testing on physical device
    // Use localhost for simulator
    #if targetEnvironment(simulator)
    static let baseURL = "http://localhost:5001"
    #else
    static let baseURL = "http://192.168.10.6:5001" // Your Mac's IP
    #endif
}

// MARK: - Parsed Transaction
struct ParsedTransaction: Identifiable, Hashable {
    let id = UUID()
    var isSelected: Bool = true
    let date: Date
    let title: String
    let amount: Double
    let isExpense: Bool
    let category: String
    let bank: String?
    let details: String?

    var formattedAmount: String {
        let sign = isExpense ? "-" : "+"
        return String(format: "%@₸%.0f", sign, abs(amount))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - API Response Models
struct ClassifyResponse: Codable {
    let bank: String?
    let transactions: [APITransaction]
    let summary: TransactionSummary?
    let error: String?
}

struct APITransaction: Codable {
    let date: String?
    let amount: Double?
    let amountRaw: String?
    let currency: String?
    let operation: String?
    let merchant: String?
    let details: String?
    let category: String?
    let bank: String?

    enum CodingKeys: String, CodingKey {
        case date, amount, currency, operation, merchant, details, category, bank
        case amountRaw = "amount_raw"
    }
}

struct TransactionSummary: Codable {
    let totalTransactions: Int
    let byCategory: [String: Int]

    enum CodingKeys: String, CodingKey {
        case totalTransactions = "total_transactions"
        case byCategory = "by_category"
    }
}

// MARK: - Category Mapping (Russian to English)
struct CategoryMapper {
    static let mapping: [String: String] = [
        "переводы": "Transfer",
        "покупки": "Shopping",
        "транспорт": "Transport",
        "супермаркеты": "Groceries",
        "рестораны и кафе": "Food",
        "подписки": "Subscriptions",
        "маркетплейсы": "Shopping",
        "другое": "Other"
    ]

    static func mapCategory(_ russianCategory: String) -> String {
        return mapping[russianCategory.lowercased()] ?? "Other"
    }
}

// MARK: - Statement Parser Service
class StatementParserService {
    static let shared = StatementParserService()

    private init() {}

    // MARK: - Parse File via API
    func parseFile(at url: URL) async throws -> [ParsedTransaction] {
        let fileExtension = url.pathExtension.lowercased()

        guard fileExtension == "pdf" else {
            throw ParserError.unsupportedFormat
        }

        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            throw ParserError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Read file data
        let fileData = try Data(contentsOf: url)

        // Send to API
        return try await classifyTransactions(pdfData: fileData, filename: url.lastPathComponent)
    }

    // MARK: - API Call
    private func classifyTransactions(pdfData: Data, filename: String) async throws -> [ParsedTransaction] {
        guard let url = URL(string: "\(APIConfig.baseURL)/classify") else {
            throw ParserError.parseError("Invalid API URL")
        }

        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        var body = Data()

        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(pdfData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ParserError.parseError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            throw ParserError.parseError("Server error: \(httpResponse.statusCode)")
        }

        // Decode response
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ClassifyResponse.self, from: data)

        if let error = apiResponse.error {
            throw ParserError.parseError(error)
        }

        // Convert API transactions to ParsedTransaction
        return apiResponse.transactions.compactMap { tx -> ParsedTransaction? in
            guard let dateStr = tx.date,
                  let date = parseDate(dateStr),
                  let amount = tx.amount else {
                return nil
            }

            let isExpense = amount < 0
            let category = CategoryMapper.mapCategory(tx.category ?? "другое")
            let title = tx.merchant ?? tx.details ?? "Unknown"

            return ParsedTransaction(
                date: date,
                title: String(title.prefix(60)),
                amount: abs(amount),
                isExpense: isExpense,
                category: category,
                bank: tx.bank ?? apiResponse.bank,
                details: tx.details
            )
        }
        .sorted { $0.date > $1.date }
    }

    // MARK: - Helpers
    private func parseDate(_ string: String) -> Date? {
        let formatters: [DateFormatter] = [
            createFormatter("yyyy-MM-dd"),
            createFormatter("dd.MM.yyyy"),
            createFormatter("dd.MM.yy")
        ]

        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    private func createFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

// MARK: - Parser Errors
enum ParserError: LocalizedError {
    case unsupportedFormat
    case emptyFile
    case pdfReadError
    case accessDenied
    case parseError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Unsupported file format. Please use PDF."
        case .emptyFile:
            return "The file appears to be empty."
        case .pdfReadError:
            return "Could not read the PDF file."
        case .accessDenied:
            return "Access to the file was denied."
        case .parseError(let message):
            return "Parse error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
