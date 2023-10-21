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
                Image("SideHustlersIconSmall")
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

                List {
                    ForEach(choreViewModel.chores, id: \.id) { chore in
                        NavigationLink(
                            destination: ChoreDetailView(
                                chore: chore,
                                selectedTab: $selectedTab,
                                contacts: $contacts,
                                onContactMakerTapped: { _ in
                                contacts.append(chore.id)
                            }
                        ))
                    {
                    VStack(alignment: .leading) {
                        Text(chore.title)
                        Text("Reward: \(chore.reward) kr")
                    }
                }
            }
        }
    }
            .onAppear {
            choreViewModel.fetchChores()
            }
        }
    }
                

    private func navigateToChoreDetail(chore: Chore) {
        NavigationLink(
            destination: ChoreDetailView(
                chore: chore,
                selectedTab: $selectedTab,
                contacts: $contacts,
                onContactMakerTapped: { _ in
                contacts.append(chore.id)
            }),
            label: {
                EmptyView()
            })
        }
    }

    struct ChoreDetailView: View {
        let chore: Chore
            @Binding var selectedTab: Int
            @Binding var contacts: [String]
            var onContactMakerTapped: (String) -> Void

                var body: some View {
                    VStack {
                        Text(chore.title)
                        Text(chore.description)
                        Text("Reward: \(chore.reward) kr")
                        Text("Created by: \(chore.createdBy)")
        
                        Button(action: {
                            addContactToFirebase(chore.createdBy)
                        }) {
                            Text("Contact Maker")
                        }
                    }
                }
    
    func addContactToFirebase(_ contactEmail: String) {
            // Look up the UID of the user with the given email
            let db = Firestore.firestore()

            // Query users to find the UID for the given email
            db.collection("users").whereField("email", isEqualTo: contactEmail).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error looking up user: \(error.localizedDescription)")
                    return
                }

                guard let document = querySnapshot?.documents.first else {
                    print("User with email not found")
                    return
                }

                let contactUID = document.documentID
                
                sendMessage(to: contactUID)
            }
        }
    
    
    func sendMessage(to receiverUID: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        // Construct the message content
        let contactEmail = currentUser.email ?? "Your email" // Replace with a default value
        let messageContent = "Hey, I'm interested in \(chore.title), contact me at \(contactEmail)."
        
        let db = Firestore.firestore()
        let messageCollection = db.collection("messages")

        let messageData = [
            "sender": currentUser.uid,
            "receiver": receiverUID,
            "content": messageContent,
            "timestamp": Timestamp(date: Date()) ] as [String: Any]

        messageCollection.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
            }
        }
    }
}
