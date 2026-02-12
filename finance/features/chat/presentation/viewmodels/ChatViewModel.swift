import SwiftUI
import Combine

// Protocol for future ML service injection
protocol AIResponseService {
    func generateResponse(to message: String) async throws -> String
}

// Default mock implementation
class MockAIService: AIResponseService {
    func generateResponse(to message: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let responses = [
            "I understand you're asking about: \(message). How can I assist you further?",
            "Thanks for your message! I'm here to help with your financial questions.",
            "Let me check that information for you...",
            "I can help you with that! What specific details would you like to know?",
            "Based on your question, here's what I found..."
        ]

        return responses.randomElement() ?? "I'm here to help!"
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    // Dependencies
    private let aiService: AIResponseService

    // State
    @Published var messages: [Message] = Message.sampleMessages
    @Published var newMessageText: String = ""
    @Published var isTyping: Bool = false
    @Published var errorMessage: String?

    init(aiService: AIResponseService = MockAIService()) {
        self.aiService = aiService
    }

    // MARK: - Actions

    func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = Message(trimmed, isFromUser: true)
        messages.append(userMessage)

        let messageText = newMessageText
        newMessageText = ""

        processAIResponse(to: messageText)
    }

    func clearConversation() {
        messages.removeAll()
    }

    // MARK: - Private

    private func processAIResponse(to message: String) {
        isTyping = true
        errorMessage = nil

        Task {
            do {
                let response = try await aiService.generateResponse(to: message)

                let aiMessage = Message(response, isFromUser: false)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    messages.append(aiMessage)
                }
                isTyping = false
            } catch {
                errorMessage = error.localizedDescription
                isTyping = false
            }
        }
    }
}
