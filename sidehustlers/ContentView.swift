//
//  ContentView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            NavigationView {
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
                            Image(systemName: "plus.square.fill").background(Color.blue)
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
                    
                    ProfileView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(4)
                }
                
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
