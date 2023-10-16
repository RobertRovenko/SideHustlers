//
//  MessagesView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MessagesTyperView: View {
    @Binding var selectedTab: Int
    let contact: String
    @State private var newMessage = ""
    @State private var messages: [Message] = []
    @Binding var contacts: [String]

    var body: some View {
        VStack {
            List(messages) { message in
                Text(message.sender)
                Text(message.content)
            }

            HStack {
                TextField("Type a message", text: $newMessage)
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
        }
        .navigationBarTitle(Text(contact), displayMode: .inline)
    }

    func sendMessage() {
      
    }

    func fetchMessages() {
       
    }
}


struct MessagesView: View {
    @Binding var selectedTab: Int
    @Binding var contacts: [String]

    init(selectedTab: Binding<Int>, contacts: Binding<[String]>) {
        self._selectedTab = selectedTab
        self._contacts = contacts

        //Fetch the user's contacts from Firebase Firestore
        fetchUserContacts()
    }

    var body: some View {
        NavigationView {
            List(contacts, id: \.self) { contact in
                NavigationLink(destination: MessagesTyperView(selectedTab: $selectedTab, contact: contact, contacts: $contacts)) {
                    Text(contact)
                }
            }
        }
    }

    func fetchUserContacts() {
        let currentUser = Auth.auth().currentUser
        let db = Firestore.firestore()

        if let userId = currentUser?.uid {
            //Reference to the user's contacts subcollection
            let contactsCollection = db.collection("users").document(userId).collection("contacts")

            contactsCollection.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching contacts: \(error.localizedDescription)")
                } else {
                    var newContacts: [String] = []
                    for document in snapshot?.documents ?? [] {
                        if let contactName = document.data()["name"] as? String {
                            newContacts.append(contactName)
                        }
                    }

                    //Update the contacts array with the fetched contacts
                    contacts = newContacts
                }
            }
        }
    }
}
