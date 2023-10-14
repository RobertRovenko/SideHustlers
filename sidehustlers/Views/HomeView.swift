//
//  HomeView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var choreViewModel: ChoreViewModel
    @State private var selectedChore: Chore?

    var body: some View {
        NavigationView {
            VStack {
                Image("SHIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                HStack {
                           Text("Available Tasks")
                               .frame(maxWidth: .infinity, alignment: .leading)
                           Spacer()
                       }
                       .padding()
                
                List(choreViewModel.chores, id: \.id) { chore in
                                  VStack(alignment: .leading) {
                                      Text(chore.title)
                                      Text("Reward: \(chore.reward) kr")
                                  }
                                  .onTapGesture {
                                      selectedChore = chore 
                                  }
                              }
                          }
                          .sheet(item: $selectedChore) { chore in
                              ChoreDetailView(chore: chore, selectedTab: $selectedTab)
                          }

                Spacer()
            }
        .onAppear {
            choreViewModel.fetchChores()
        
        }
    }
}


struct ChoreDetailView: View {
    let chore: Chore
    @Binding var selectedTab: Int
    @State private var isMessagingSheetPresented = false
    @EnvironmentObject var choreViewModel: ChoreViewModel
    var body: some View {
        VStack {
            Text("\(chore.title)")
            Text("\(chore.description)")
            Text("Reward: \(chore.reward) kr")
            Text("Created by: \(chore.createdBy)")

            Button(action: {
                isMessagingSheetPresented.toggle()
                choreViewModel.addContact(chore.createdBy)
            }) {
                Text("Contact Maker")
            }
            .sheet(isPresented: $isMessagingSheetPresented) {
                MessagesView(selectedTab: $selectedTab, currentContact: chore.createdBy)
            }
        }
    }
}

