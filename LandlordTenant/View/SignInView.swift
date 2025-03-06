//
//  SignInView.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct SignInView: View {
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    @Binding var rootScreen: RootView
    
    @State private var email : String = ""
    @State private var password : String = ""
    
    private let gridItems : [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            Form {
                TextField("Enter Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Enter Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            
            LazyVGrid(columns: gridItems) {
                Button(action: {
                    fireAuthHelper.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .background(Color.blue)
                }
                .alert("SignIn Success", isPresented: $fireAuthHelper.isSuccess) {
                    Button("Ok") {
                        fireAuthHelper.isSuccess = false
                        rootScreen = .PropertyList
                    }
                }
                
                Button(action: {
                    rootScreen = .SignUp
                }){
                    Text("Sign Up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .background(Color.blue)
                }
            }
            Spacer()
        }
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignInView(rootScreen: .constant(.Login))
}

