//
//  AuthenticationView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @Binding var isAuthViewPresented: Bool
    @Binding var isUserLoggedIn: Bool
    @ObservedObject var userSettings: UserSettings

    var body: some View {
        NavigationView {
            VStack {
              Spacer()
                ZStack {
                    
                    Spacer()
                    
                    GeometryReader { geometry in
                        Color.clear
                            .frame(maxHeight: geometry.size.height * 0.2)
                        }
                        Image("AuthenticationLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .offset(y: -40)
                             }
                
                Text("Welcome")
                    .padding()
                    .font(.title)
                
                CustomTextField(placeholder: "Email", text: $email, imageName: "envelope")
                SecureTextField(placeholder: "Password", text: $password, imageName: "lock")
                
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()

                Button("Log In") {
                    do {
                        try Auth.auth().signOut()
                        UserDefaults.standard.removeObject(forKey: "userEmail")
                        userSettings.updateEmail("Welcome")
                        isUserLoggedIn = false

                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                errorMessage = "\(error.localizedDescription)"
                            } else {
                                if let user = Auth.auth().currentUser {
                                    UserDefaults.standard.set(user.email, forKey: "userEmail")
                                    userSettings.updateEmail(user.email ?? "")
                                }
                                isUserLoggedIn = true
                                isAuthViewPresented = false
                            }
                        }
                    } catch {
                        errorMessage = "\(error.localizedDescription)"
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()

              

                Button("Sign Up") {
                            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                if let error = error {
                                    errorMessage = "\(error.localizedDescription)"
                                } else {
                                    if let user = Auth.auth().currentUser {
                                        let db = Firestore.firestore()
                                        
                                        let userDocRef = db.collection("users").document(user.uid)
                                        userDocRef.setData([
                                            "uid": user.uid,
                                            "email": user.email ?? ""
                                        ]) { error in
                                            if let error = error {
                                                errorMessage = "\(error.localizedDescription)"
                                            } else {
                                                isAuthViewPresented = false
                                                isUserLoggedIn = true
                                                UserDefaults.standard.set(user.email, forKey: "userEmail")
                                                userSettings.updateEmail(user.email ?? "")
                                            }
                                        }
                                    }

                                }
                            }
                        }
                        .padding()
                    Spacer()
            }
            .padding()
            Spacer()
        }
    }
}


struct SecureTextField: View {
    var placeholder: String
    @Binding var text: String
    var imageName: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Color.secondary)
                .frame(width: 30, height: 30)

            SecureField(placeholder, text: $text)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5))
        .padding(.horizontal)
    }
}


struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var imageName: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Color.secondary)
                .frame(width: 30, height: 30)

            TextField(placeholder, text: $text)
                .font(.headline)
                .foregroundColor(.primary)
                .autocapitalization(.none)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.5))
        .padding(.horizontal)
    }
}
