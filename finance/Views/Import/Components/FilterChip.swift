import SwiftUI

struct FilterChip: View {
    let title: String
    let count: Int
    var color: Color = .appPrimary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title != "All" {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.2) : Color.appBorder)
                    .cornerRadius(8)
            }
            .foregroundColor(isSelected ? .white : .appTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.appCardBackground)
            .cornerRadius(20)
        }
    }
}
