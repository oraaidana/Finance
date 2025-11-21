//
//  AccountView().swift
//  finance
//
//  Created by Aidana Orazbay on 11/21/25.
//

import SwiftUI
import Foundation

struct AccountView: View {
    var body: some View {
        VStack(){
            Text("Account")
                .navigationBarTitle("Account")
            HStack{
                Text("Name")
                Spacer()
                Text("Surename")
            }.padding()
        }
    }
}
