//
//  AccountRepositoryProtocol.swift
//  finance
//
//  Protocol defining the interface for account/card data operations.
//  Used for dependency injection instead of singleton access.
//

import Foundation
import Combine

protocol AccountRepositoryProtocol: ObservableObject {
    var cards: [Card] { get }
    var selectedCardId: UUID? { get set }
    var selectedCard: Card? { get }

    func addCard(_ card: Card)
    func updateCard(_ card: Card)
    func deleteCard(_ card: Card)
    func moveCards(from source: IndexSet, to destination: Int)
    func selectCard(_ card: Card)
    func updateBalance(for cardId: UUID, amount: Double, isExpense: Bool)
}
