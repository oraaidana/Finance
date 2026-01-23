import SwiftUI

struct AccountRow: View {
    let card: Card
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Card icon
            Image(systemName: card.icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(card.color.color)
                .cornerRadius(10)

            // Card name
            Text(card.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)

            Spacer()

            // Balance
            Text(card.formattedBalance)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
