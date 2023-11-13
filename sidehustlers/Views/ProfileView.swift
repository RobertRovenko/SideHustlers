//
//  ProfileView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int
    @Binding var isAuthViewPresented: Bool
    @State private var isNotificationsEnabled = true
    @State private var showAlert = false
    @State private var alertType: AlertType? = nil
    @State private var alertMessage = ""
    @State private var userUID = ""
    @AppStorage("savedProfileImageURL") private var savedProfileImageURL: String = ""
    
    enum AlertType {
        case logOut
        case deleteAccount
    }
    
    @State private var userEmail: String = "Welcome!"
    @ObservedObject var userSettings: UserSettings
    @State private var profileImage: Image?
    @State private var profileImageURL: String = "" 
    @StateObject private var imageLoader: ImageLoader = ImageLoader()
    @AppStorage("isDarkThemeEnabled") private var isDarkThemeEnabled = false
    @ObservedObject var choreViewModel: ChoreViewModel = ChoreViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Button(action: {
                                  
                    fetchRandomProfileImage()
                    
                }) {
                    if let image = imageLoader.image {
                     image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    } else {
                        Image("SideHustlersIconSmall") // Use a placeholder image here
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    }
                }

                Spacer()
                
                Text(userEmail)
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
                        deleteAccount(isAuthViewPresented: $isAuthViewPresented, choreViewModel: choreViewModel)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .preferredColorScheme(isDarkThemeEnabled ? .dark : .light)
        .onAppear {
            if let storedEmail = UserDefaults.standard.string(forKey: "userEmail") {
                userEmail = storedEmail
            } else if let user = Auth.auth().currentUser {
                userEmail = user.email ?? "Welcome!"
                UserDefaults.standard.set(userEmail, forKey: "userEmail")
                userUID = user.uid
                print("User UID: \(userUID)")
            }

         
            // Load the saved profile picture URL
               if let savedURL = UserDefaults.standard.string(forKey: "savedProfileImageURL"), !savedURL.isEmpty {
                   profileImageURL = savedURL
                   imageLoader.loadImage(from: savedURL)
               }
        }
        
    }
    func fetchRandomProfileImage() {
        // Always fetch a new random image
        PexelsAPI.fetchRandomProfileImage { imageURL in
            if let imageURL = imageURL {
                // Save the selected profile picture URL in UserDefaults
                savedProfileImageURL = imageURL
                
                // Load the image using the ImageLoader
                imageLoader.loadImage(from: imageURL)
            }
        }
    }

}


func deleteAccount(isAuthViewPresented: Binding<Bool>, choreViewModel: ChoreViewModel) {
    let user = Auth.auth().currentUser
    
    user?.delete { error in
        if let error = error {
            print("Error deleting account: \(error.localizedDescription)")
        } else {
            print("Account deleted successfully")
            choreViewModel.deleteAllChoresForUser(userUID: user?.uid ?? "")
            deleteCurrentUserDocument(userUID: user?.uid ?? "")
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "userEmail")
                isAuthViewPresented.wrappedValue = true
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
}

func deleteCurrentUserDocument(userUID: String) {
    let usersCollection = Firestore.firestore().collection("users")
    
    usersCollection.document(userUID).delete { error in
        if let error = error {
            print("Error deleting user document: \(error.localizedDescription)")
        } else {
            print("User document deleted successfully")
        }
    }
}
func logOut(isAuthViewPresented: Binding<Bool>) {
    do {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isAuthViewPresented.wrappedValue = true
    } catch {
        print("Error signing out: \(error.localizedDescription)")
    }
}
