//
//  ContentView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isUserLoggedIn = false
    @State private var isAuthViewPresented = false

    var body: some View {
        NavigationView {
            if isUserLoggedIn {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)

                    MessagesView(selectedTab: $selectedTab)
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

                    FinderView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "map.fill")
                            Text("Finder")
                        }
                        .tag(3)

                    ProfileView(selectedTab: $selectedTab, isAuthViewPresented: $isAuthViewPresented)
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
            AuthentictionView(isAuthViewPresented: $isAuthViewPresented, isUserLoggedIn: $isUserLoggedIn )
        }
        .onAppear {
            isUserLoggedIn = Auth.auth().currentUser != nil
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
