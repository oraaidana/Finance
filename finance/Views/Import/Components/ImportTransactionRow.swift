import SwiftUI

struct ImportTransactionRow: View {
    @Binding var transaction: ParsedTransaction

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: categoryIcon)
                    .font(.system(size: 16))
                    .foregroundColor(categoryColor)
            }

            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(transaction.category)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(categoryColor)

                    Text("•")
                        .foregroundColor(.appTextSecondary)

                    Text(transaction.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isExpense ? .appExpense : .appIncome)

                // Checkbox
                Image(systemName: transaction.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(transaction.isSelected ? .appIncome : .appBorder)
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(transaction.isSelected ? Color.appIncome.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                transaction.isSelected.toggle()
            }
        }
    }

    private var categoryColor: Color {
        switch transaction.category.lowercased() {
        case "food": return .orange
        case "groceries": return .green
        case "transport": return .blue
        case "shopping": return .pink
        case "subscriptions": return .purple
        case "transfer": return .cyan
        case "entertainment": return .yellow
        case "health": return .red
        default: return .gray
        }
    }

    private var categoryIcon: String {
        switch transaction.category.lowercased() {
        case "food": return "fork.knife"
        case "groceries": return "cart.fill"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "subscriptions": return "repeat"
        case "transfer": return "arrow.left.arrow.right"
        case "entertainment": return "gamecontroller.fill"
        case "health": return "heart.fill"
        default: return "questionmark.circle"
        }
    }
}
