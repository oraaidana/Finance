//
//  TransactionsView.swift
//  finance
//
//  Created by Claude on 02/10/26.
//

import SwiftUI

struct TransactionsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Transactions")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Transaction history coming soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionsView()
}
