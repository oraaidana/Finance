import SwiftUI

struct CategoryManagerRow: View {
    let category: SpendingCategory
    let onToggleVisibility: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Emoji
            Text(category.emoji)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .cornerRadius(12)

            // Name
            Text(category.name)
                .font(.body)
                .foregroundColor(.appTextPrimary)

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.appError.opacity(0.8))
            }
            .buttonStyle(.plain)

            // Visibility toggle
            Button(action: onToggleVisibility) {
                Image(systemName: category.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(category.isVisible ? .appTextSecondary : .appTextSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}
