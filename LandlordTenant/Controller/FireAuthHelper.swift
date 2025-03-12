//
//  FireAuthHelper.swift
//  LandlordTenant
//
//  Created by Henrique Machitte on 06/03/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireAuthHelper: ObservableObject {
    private static var shared: FireAuthHelper?
    @Published var isSuccess = false
    private let db = Firestore.firestore()

    static func getInstance() -> FireAuthHelper {
        if shared == nil {
            shared = FireAuthHelper()
        }
        return shared!
    }
    
    @Published var user: UserModel? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func signUp(email: String, password: String, user: UserModel) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Signup failed: \(error.localizedDescription)")
                return
            }

            guard let uid = result?.user.uid else { return }

            var userData = user
            userData.id = uid

            do {
                try self.db.collection("users").document(uid).setData(from: userData)
                self.user = userData
                self.isSuccess = true
                print("User created successfully: \(user.name)")
            } catch {
                print("Error saving user data: \(error.localizedDescription)")
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Signin failed: \(error.localizedDescription)")
                return
            }

            guard let uid = result?.user.uid else { return }

            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        self.user = try snapshot.data(as: UserModel.self)
                        self.isSuccess = true
                        print("User signed in: \(self.user?.name ?? "Unknown")")
                    } catch {
                        print("Error fetching user data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // Logout function
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSuccess = false
            print("User signed out successfully.")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
//    func addPropertyToUser(userID: String, propertyID: String) {
//        let userRef = db.collection("users").document(userID)
//        
//        userRef.updateData([
//            "propertyIDs": FieldValue.arrayUnion([propertyID])
//        ]) { error in
//            if let error = error {
//                print("Failed to add property: \(error.localizedDescription)")
//            } else {
//                print("Property \(propertyID) added successfully to user \(userID)")
//            }
//        }
//    }
//    
//    func removePropertyFromUser(userID: String, propertyID: String) {
//        let userRef = db.collection("users").document(userID)
//        
//        userRef.updateData([
//            "propertyIDs": FieldValue.arrayRemove([propertyID])
//        ]) { error in
//            if let error = error {
//                print("Failed to remove property: \(error.localizedDescription)")
//            } else {
//                print("Property \(propertyID) removed successfully from user \(userID)")
//            }
//        }
//    }
    func toggleFavoriteProperty(propertyId: String) {
        guard let user = user else {
            print("No authenticated user")
            return
        }

        let userRef = db.collection("users").document(user.id!)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                var propertyIDs = document.data()?["propertyIDs"] as? [String] ?? []

                if propertyIDs.contains(propertyId) {
                    // Remove from favorites
                    propertyIDs.removeAll { $0 == propertyId }
                } else {
                    // Add to favorites
                    propertyIDs.append(propertyId)
                }

                // Update Firestore
                userRef.updateData(["propertyIDs": propertyIDs]) { error in
                    if let error = error {
                        print("Error updating favorites: \(error.localizedDescription)")
                    } else {
                        print("Favorites updated successfully")
                        self.user?.propertyIDs = propertyIDs // Update local user data
                    }
                }
            }
        }
    }
    
    func requestProperty(propertyId: String) {
        guard let user = user else {
            print("No authenticated user")
            return
        }

        let userRef = db.collection("users").document(user.id!)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                var propertyIDs = document.data()?["requestpropertyIDs"] as? [String] ?? []

                if propertyIDs.contains(propertyId) {
                    // Remove from favorites
                    propertyIDs.removeAll { $0 == propertyId }
                } else {
                    // Add to favorites
                    propertyIDs.append(propertyId)
                }

                // Update Firestore
                userRef.updateData(["requestpropertyIDs": propertyIDs]) { error in
                    if let error = error {
                        print("Error updating requests: \(error.localizedDescription)")
                    } else {
                        print("request updated successfully")
                        self.user?.propertyIDs = propertyIDs // Update local user data
                    }
                }
            }
        }
    }




}
