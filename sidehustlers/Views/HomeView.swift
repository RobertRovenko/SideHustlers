//
//  HomeView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var choreViewModel: ChoreViewModel
    @State private var selectedChore: Chore?
    @Binding var contacts: [String]
    @StateObject var contactViewModel = ContactViewModel()
    
    @State private var isChoreDetailPresented = false
    @State private var choreDetailContact: String = ""

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
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()

                List(choreViewModel.chores, id: \.id) { chore in
                    VStack(alignment: .leading) {
                        Text(chore.title)
                        Text("Reward: \(chore.reward) kr")
                    }
                    .onTapGesture {
                        choreDetailContact = chore.createdBy
                        isChoreDetailPresented.toggle()
                    }
                }
            }
            .onAppear {
                choreViewModel.fetchChores()
            }
        }
        .sheet(isPresented: $isChoreDetailPresented) {
            if let chore = choreViewModel.chores.first(where: { $0.createdBy == choreDetailContact }) {
                ChoreDetailView(
                    chore: chore,
                    selectedTab: $selectedTab,
                    isChoreDetailPresented: $isChoreDetailPresented,
                    contacts: $contacts,
                    onContactMakerTapped: {_ in 
                        contacts.append(choreDetailContact)
                        isChoreDetailPresented = false
                    }
                )
            } else {
                Text("Chore not found")
            }
        }
    }
}


struct ChoreDetailView: View {
    let chore: Chore
    @Binding var selectedTab: Int
    @EnvironmentObject var choreViewModel: ChoreViewModel
    @Binding var isChoreDetailPresented: Bool
    @Binding var contacts: [String]
    
    //Closure to handle Contact Maker
    var onContactMakerTapped: (String) -> Void
    
    var body: some View {
        VStack {
            Text("\(chore.title)")
            Text("\(chore.description)")
            Text("Reward: \(chore.reward) kr")
            Text("Created by: \(chore.createdBy)")
            
            Button(action: {
                //Integrate Firebase code to add a contact
                addContactToFirebase(chore.createdBy)
            }) {
                Text("Contact Maker")
            }
        }
        .onDisappear {
            //Close the ChoreDetailView when it disappears
            isChoreDetailPresented = false
        }
    }
    
    func addContactToFirebase(_ contact: String) {
        let currentUser = Auth.auth().currentUser
        let db = Firestore.firestore()
        
        if let userId = currentUser?.uid {
            //Define the data to be added to the contact document
            let contactData: [String: Any] = [
                "name": contact,
                //Add other contact information here if needed
            ]
            
            //Reference to the user's contacts subcollection
            let contactsCollection = db.collection("users").document(userId).collection("contacts")
            
            //Add the contact document to the contacts subcollection
            contactsCollection.addDocument(data: contactData) { error in
                if let error = error {
                    print("Error adding contact: \(error.localizedDescription)")
                } else {
                    //Successfully added the contact to Firestore
                    contacts.append(contact)
                }
            }
        }
    }
}
