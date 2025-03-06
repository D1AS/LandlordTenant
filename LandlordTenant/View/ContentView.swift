//
//  ContentView.swift
//  LandlordTenant
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct ContentView: View {
    
    // This is a second comment
    
    @State private var root: RootView = .Login
    
    var fireAuthHelper = FireAuthHelper.getInstance()
    
    var body: some View {

        NavigationStack {
            
            switch root {
            case .Login:
                SignInView(rootScreen: self.$root)
                    .environmentObject(self.fireAuthHelper)
            case .SignUp:
                SignUpView(rootScreen: self.$root)
                    .environmentObject(self.fireAuthHelper)
            case .PropertyList:
                PropertyListView(rootScreen: self.$root)
                    .environmentObject(self.fireAuthHelper)
            }
        }
    }
}

enum RootView {
    case Login, SignUp, PropertyList
}

#Preview {
    ContentView()
}

