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
                           
                            isAuthViewPresented = false
                            isUserLoggedIn = true
                        }
                    }
                }

                Button("Log In") {
                           Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                               if let error = error {
                                   print("Error logging in: \(error.localizedDescription)")
                               } else {
                                   
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
