//
//  FireAuthHelper.swift
//  LandlordTenandt
//
//  Created by Henrique Machitte on 02/03/25.
//

import Foundation
import FirebaseAuth

class FireAuthHelper: ObservableObject {
    private static var shared : FireAuthHelper?
    @Published var isSuccess = false
    
    static func getInstance() -> FireAuthHelper{
        if (shared == nil){
            shared = FireAuthHelper()
        }
        return shared!
    }
    
    @Published var user: User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func signUp(email : String, password : String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let response = result else {
                print(error?.localizedDescription ?? "Signup Failed")
                return
            }
            
            print("Response: \(response)")
            
            switch result {
            case .none:
                print("Unable to create a user")
            case .some(_):
                print("User created successfully")
                self.user = result?.user
                UserDefaults.standard.set(email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                self.isSuccess = true
            }
        }
    }
    
    func signIn(email : String, password : String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard let response = result else {
                print(error?.localizedDescription ?? "Signin Failed")
                return
            }
            
            print("Response: \(response)")
            
            switch result {
            case .none:
                print("Unable to sign-in")
            case .some(_):
                print("Sign-in successful")
                self.user = result?.user
                UserDefaults.standard.set(self.user?.email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                self.isSuccess = true
            }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch let err as NSError{
            print("Unable to sign out \(err)")
        }
    }
}
