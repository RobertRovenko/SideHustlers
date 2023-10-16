//
//  AuthenticationView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct AuthentictionView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isAuthViewPresented: Bool
    @Binding var isUserLoggedIn: Bool
    @ObservedObject var userSettings: UserSettings
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Sign Up") {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            print("Error signing up: \(error.localizedDescription)")
                        } else {
                            //User is signed up, save their profile to Firestore
                            let user = Auth.auth().currentUser
                            let db = Firestore.firestore()
                            if let user = user {
                                db.collection("users").document(user.uid).setData([
                                    "email": user.email ?? ""
                                ]) { error in
                                    if let error = error {
                                        print("Error saving user profile: \(error.localizedDescription)")
                                    } else {
                                        //User profile saved, update authentication state
                                        isAuthViewPresented = false
                                        isUserLoggedIn = true
                                    }
                                }
                            }
                        }
                    }
                }

                Button("Log In") {
                       Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                           if let error = error {
                               print("Error logging in: \(error.localizedDescription)")
                           } else {
                               if let user = Auth.auth().currentUser {
                                   UserDefaults.standard.set(user.email, forKey: "userEmail")
                                   userSettings.updateEmail(user.email ?? "") // Update the email
                               }
                               isUserLoggedIn = true
                               isAuthViewPresented = false
                           }
                       }
                   }

            }
            .padding()
            Spacer()
        }
    }
}
