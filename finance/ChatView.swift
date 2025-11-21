// Views/ChatView.swift
import SwiftUI
// Views/MessageInputBar.swift
import SwiftUI

struct MessageInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Text field
            HStack {
                TextField("iMessage", text: $text)
                    .padding(.vertical, 8)
                    .padding(.leading, 12)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 8)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            
            // Send button
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? .gray : .blue)
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
// Views/MessagesListView.swift
import SwiftUI
// Models/Message.swift
import Foundation
import SwiftUI

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
struct MessagesListView: View {
    let messages: [Message]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.vertical, 8)
            }
            .onAppear {
                // Scroll to bottom when messages appear
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: messages) { oldValue, newValue in
                // Scroll to bottom when new messages are added
                if let lastMessage = newValue.last {
                    withAnimation(.spring()) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
// Views/MessageBubble.swift
import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromUser ? Color.blue : Color(.systemGray5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
    }
}
struct ChatView: View {
    @State private var messages: [Message] = Message.sampleMessages
    @State private var newMessageText: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                MessagesListView(messages: messages)
                    .background(Color(.white))
                
                // Typing indicator
                if isTyping {
                    HStack {
                        TypingIndicator()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
                
                // Input bar
                MessageInputBar(text: $newMessageText) {
                    sendMessage()
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Clear conversation
                        messages.removeAll()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(newMessageText, isFromUser: true)
        messages.append(userMessage)
        
        // Clear input
        let messageText = newMessageText
        newMessageText = ""
        
        // Simulate AI response
        simulateAIResponse(to: messageText)
    }
    
    private func simulateAIResponse(to message: String) {
        isTyping = true
        
        // Simulate typing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            
            let responses = [
                "I understand you're asking about: \(message). How can I assist you further?",
                "Thanks for your message! I'm here to help with your financial questions.",
                "Let me check that information for you...",
                "I can help you with that! What specific details would you like to know?",
                "Based on your question, here's what I found..."
            ]
            
            let response = responses.randomElement() ?? "I'm here to help!"
            let aiMessage = Message(response, isFromUser: false)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                messages.append(aiMessage)
            }
        }
    }
}

// Typing indicator
struct TypingIndicator: View {
    @State private var animationCount = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.white)
                    .opacity(animationCount >= index ? 1 : 0.3)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.4)) {
                animationCount = (animationCount + 1) % 4
            }
        }
    }
}

#Preview {
    ChatView()
}
