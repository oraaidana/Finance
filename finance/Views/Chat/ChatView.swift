import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                MessagesListView(messages: viewModel.messages)
                    .background(Color.appCardBackground)

                // Typing indicator
                if viewModel.isTyping {
                    HStack {
                        TypingIndicator()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }

                // Input bar
                MessageInputBar(text: $viewModel.newMessageText) {
                    viewModel.sendMessage()
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.clearConversation()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
