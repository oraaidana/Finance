//
//  ContentView.swift
//  finance
//
//  Created by Aidana Orazbay on 11/20/25.
//

import SwiftUI

// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "star.fill").ignoresSafeArea()
        }
        TabView {
            // Main financial dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Dashboard")
                }
            
            // Budget view
            BudgetView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Budget")
                }
            
            // Settings
            ChatView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Chat")
                }
            AccountView()
                .tabItem {
                Image(systemName: "star")
                Text("Account")
            }
        }
        .accentColor(.blue) // Primary color
        
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
#Preview {
    ContentView().environmentObject(SharedDataManager()) // Add this line to provide the environment object

}
