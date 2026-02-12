//
//  CardManager.swift
//  finance
//
//  Created by Claude on 01/24/26.
//
//  Implementation of AccountRepositoryProtocol.
//  Manages card/account data with UserDefaults persistence.
//

import SwiftUI
import Combine

class CardManager: ObservableObject, AccountRepositoryProtocol {
    static let shared = CardManager()

    @Published var cards: [Card] = []
    @Published var selectedCardId: UUID?

    private let cardsKey = "user_cards"
    private let selectedCardKey = "selected_card_id"

    var selectedCard: Card? {
        guard let id = selectedCardId else { return cards.first }
        return cards.first { $0.id == id }
    }

    init() {
        loadCards()
        loadSelectedCard()
    }

    // MARK: - Card CRUD

    func addCard(_ card: Card) {
        cards.append(card)
        saveCards()
        if selectedCardId == nil {
            selectedCardId = card.id
            saveSelectedCard()
        }
    }

    func updateCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }

    func deleteCard(_ card: Card) {
        cards.removeAll { $0.id == card.id }
        if selectedCardId == card.id {
            selectedCardId = cards.first?.id
            saveSelectedCard()
        }
        saveCards()
    }

    func moveCards(from source: IndexSet, to destination: Int) {
        cards.move(fromOffsets: source, toOffset: destination)
        saveCards()
    }

    func selectCard(_ card: Card) {
        selectedCardId = card.id
        saveSelectedCard()
    }

    // MARK: - Balance Updates

    func updateBalance(for cardId: UUID, amount: Double, isExpense: Bool) {
        if let index = cards.firstIndex(where: { $0.id == cardId }) {
            if isExpense {
                cards[index].balance -= amount
            } else {
                cards[index].balance += amount
            }
            saveCards()
        }
    }

    // MARK: - Persistence

    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: cardsKey)
        }
    }

    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: cardsKey),
           let decoded = try? JSONDecoder().decode([Card].self, from: data) {
            cards = decoded
        } else {
            // Load default card for first time
            cards = [Card.defaultCard]
            saveCards()
        }
    }

    private func saveSelectedCard() {
        if let id = selectedCardId {
            UserDefaults.standard.set(id.uuidString, forKey: selectedCardKey)
        }
    }

    private func loadSelectedCard() {
        if let idString = UserDefaults.standard.string(forKey: selectedCardKey),
           let id = UUID(uuidString: idString) {
            selectedCardId = id
        } else {
            selectedCardId = cards.first?.id
        }
    }
}
