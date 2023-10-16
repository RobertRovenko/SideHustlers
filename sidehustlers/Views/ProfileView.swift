//
//  ProfileView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @Binding var selectedTab: Int
    @Binding var isAuthViewPresented: Bool
    @State private var isDarkThemeEnabled = false
    @State private var isNotificationsEnabled = true
    
    enum AlertType {
        case logOut
        case deleteAccount
    }
    
    var userEmail: String? {
        return Auth.auth().currentUser?.email
    }

    @State private var showAlert = false
    @State private var alertType: AlertType? = nil
    @State private var alertMessage = ""

    
    var body: some View {
        NavigationView {
            VStack {
                
                Spacer()
                
                Text(userEmail ?? "User's Name")
                    .font(.title)
                
                
                Spacer()
                
                Toggle(isOn: $isDarkThemeEnabled) {
                    Text("Dark Theme")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
                
                Toggle(isOn: $isNotificationsEnabled) {
                    Text("Notifications")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
                
                Spacer()
                
                HStack {
                    
                    Button("Log Out") {
                        alertType = .logOut
                        alertMessage = "Are you sure you want to log out?"
                        showAlert = true
                    }
                    .padding()
                    
                    
                    Button("Delete Account") {
                        alertType = .deleteAccount
                        alertMessage = "Are you sure you want to delete your account?"
                        showAlert = true
                    }
                    .padding()
                    .foregroundColor(.red)
                    
                }
                .padding()
            }
            .padding()
        }
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Confirm")) {
                    if alertMessage == "Are you sure you want to log out?" {
                        logOut(isAuthViewPresented: $isAuthViewPresented)
                    } else if alertMessage == "Are you sure you want to delete your account?" {
                        deleteAccount(isAuthViewPresented: $isAuthViewPresented)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}


func deleteAccount(isAuthViewPresented: Binding<Bool>) {
    let user = Auth.auth().currentUser

    user?.delete { error in
        if let error = error {
            print("Error deleting account: \(error.localizedDescription)")
           
        } else {
            print("Account deleted successfully")
          
            do {
                try Auth.auth().signOut()
                    isAuthViewPresented.wrappedValue = true
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
           
        }
    }
}

func logOut(isAuthViewPresented: Binding<Bool>) {
    do {
        try Auth.auth().signOut()
        isAuthViewPresented.wrappedValue = true
    } catch {
        print("Error signing out: \(error.localizedDescription)")
    }
}
