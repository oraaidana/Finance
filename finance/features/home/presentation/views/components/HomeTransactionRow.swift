import SwiftUI

struct HomeTransactionRow: View {
    let transaction: Transaction
    let categoryManager: CategoryManager

    private var categoryEmoji: String {
        categoryManager.categories
            .first { $0.name.lowercased() == transaction.category.lowercased() }?
            .emoji ?? "📦"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category emoji
            Text(categoryEmoji)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .cornerRadius(12)

            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            // Amount and date
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isExpense ? .appExpense : .appIncome)

                Text(transaction.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}
