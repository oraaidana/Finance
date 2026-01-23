import Foundation

struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date

    init(_ text: String, isFromUser: Bool = false, timestamp: Date = Date()) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// Sample data
extension Message {
    static let sampleMessages: [Message] = [
        Message("Hello! How can I help you with your finances today?", isFromUser: false),
        Message("I want to check my account balance", isFromUser: true),
        Message("Your current balance is $2,458.32", isFromUser: false),
        Message("Can you show me my recent transactions?", isFromUser: true),
        Message("Sure! Here are your last 5 transactions...", isFromUser: false)
    ]
}
