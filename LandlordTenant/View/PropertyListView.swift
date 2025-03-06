//
//  PropertyListView.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct PropertyListView: View {
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    @Binding var rootScreen: RootView
    
    var body: some View {
        VStack {
            Text("Welcome to Property Listings")
                .font(.title)
                .padding()
            
            Button(action: {
                fireAuthHelper.signOut()
                rootScreen = .Login
            }) {
                Text("Sign Out")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    PropertyListView(rootScreen: .constant(.PropertyList))
}

