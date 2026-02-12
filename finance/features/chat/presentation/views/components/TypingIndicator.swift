import SwiftUI

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
