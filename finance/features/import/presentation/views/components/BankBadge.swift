import SwiftUI

struct BankBadge: View {
    let name: String
    var color: Color = .gray

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appTextSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.appCardBackground)
        .cornerRadius(8)
    }
}
