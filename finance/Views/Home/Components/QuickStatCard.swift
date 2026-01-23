import SwiftUI

struct QuickStatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(CurrencyFormatter.shared.format(amount, currency: .kzt))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            Spacer()
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}
