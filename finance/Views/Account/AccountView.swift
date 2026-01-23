//
//  AccountView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/21/25.
//

import SwiftUI
import Foundation

struct AccountView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Account")
                    .font(.title)
                    .padding()
                
                HStack {
                    Text("Name")
                    Spacer()
                    Text("Surname")
                }
                .padding()
                
                Spacer()
                
                // Logout button
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("Logout")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appError)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .navigationTitle("Account")
        }
    }
}
