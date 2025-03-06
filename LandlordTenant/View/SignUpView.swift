//
//  SignUpView.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    @Binding var rootScreen: RootView
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("Enter Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Enter Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            
            Section {
                Button(action: {
                    fireAuthHelper.signUp(email: email, password: password)
                }) {
                    Text("Create Account")
                }
                .disabled( self.password != self.confirmPassword || self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty)
                .alert("SignUp Success", isPresented: $fireAuthHelper.isSuccess) {
                    Button("Ok") {
                        fireAuthHelper.isSuccess = false
                        rootScreen = .PropertyList
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Registration")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpView(rootScreen: .constant(.SignUp))
}

