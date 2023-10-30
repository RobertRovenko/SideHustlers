//
//  ContentView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isUserLoggedIn = false
    @State private var isAuthViewPresented = false
    @State private var contacts: [String] = []
    @StateObject private var choreViewModel = ChoreViewModel()
    @StateObject private var userSettings = UserSettings()
    @StateObject var messageManager = MessageManager()
    @State private var userUID: String = ""
    
    var body: some View {
        NavigationView {
            if isUserLoggedIn {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab, choreViewModel: choreViewModel, messageManager: messageManager, contacts: $contacts)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)

                    MessagesView(selectedTab: $selectedTab, messageManager: messageManager)
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Messages")
                        }
                        .tag(1)

                    PostView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "plus.square.fill")
                                .background(Color.blue)
                                .clipShape(Circle())
                            Text("Post")
                        }
                        .tag(2)

                    TasksView(selectedTab: $selectedTab)
                        .environmentObject(choreViewModel)
                        .tabItem {
                            Image(systemName: "text.justify")
                            Text("Tasks")
                        }
                        .tag(3)

                    ProfileView(selectedTab: $selectedTab, isAuthViewPresented: $isAuthViewPresented, userSettings: userSettings  )
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(4)
                }
            } else {
                Text("User not logged in")
                    .onAppear {
                        isAuthViewPresented = true
                    }
            }
        }
        .fullScreenCover(isPresented: $isAuthViewPresented) {
            AuthenticationView(isAuthViewPresented: $isAuthViewPresented, isUserLoggedIn: $isUserLoggedIn, userSettings: userSettings)
        }

        .onAppear {
            isUserLoggedIn = Auth.auth().currentUser != nil
            if let user = Auth.auth().currentUser {
                let userUID = user.uid
                choreViewModel.fetchChoresForUser(userUID: userUID)
                isUserLoggedIn = true
                messageManager.loadMessagesAndContacts()
                messageManager.fetchContactedUsers()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

