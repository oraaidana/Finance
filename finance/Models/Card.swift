//
//  Card.swift
//  finance
//
//  Created by Claude on 01/24/26.
//

import SwiftUI

struct Card: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var currency: String
    var balance: Double
    var color: CardColor
    var icon: String

    init(id: UUID = UUID(), name: String, currency: String = "KZT", balance: Double = 0, color: CardColor = .blue, icon: String = "creditcard.fill") {
        self.id = id
        self.name = name
        self.currency = currency
        self.balance = balance
        self.color = color
        self.icon = icon
    }

    var currencySymbol: String {
        switch currency {
        case "KZT": return "₸"
        case "USD": return "$"
        case "EUR": return "€"
        case "RUB": return "₽"
        default: return currency
        }
    }

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: balance)) ?? "0.00"
        return "\(formatted) \(currencySymbol)"
    }
}

enum CardColor: String, Codable, CaseIterable {
    case blue, green, purple, orange, red, pink, teal

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .teal: return .teal
        }
    }
}

// MARK: - Default Card
extension Card {
    static let defaultCard: Card = Card(
        name: "Card",
        currency: "KZT",
        balance: 0,
        color: .blue,
        icon: "creditcard.fill"
    )
}
