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
                        VStack(alignment: .leading) {
                            Text(chore.title)
                            Text("Reward: \(chore.reward) kr")
                        }
                        .onTapGesture {
                            choreDetailContact = chore.id
                            isChoreDetailPresented.toggle()
                        }
                        
                    }
                }
               
             
            }
            .onAppear {
                choreViewModel.fetchChores()
            }
        }
        .sheet(isPresented: $isChoreDetailPresented) {
            if let chore = choreViewModel.chores.first(where: { $0.id == choreDetailContact }) {
                ChoreDetailView(
                    chore: chore,
                    selectedTab: $selectedTab,
                    isChoreDetailPresented: $isChoreDetailPresented,
                    contacts: $contacts,
                    onContactMakerTapped: { _ in
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
            let messageContent = "Hey, I'm interested in your job offer, contact me at \(contactEmail)."

            let db = Firestore.firestore()
            let messageCollection = db.collection("messages")

            let messageData = [
                "sender": currentUser.uid,
                "receiver": receiverUID,
                "content": messageContent,
                "timestamp": Timestamp(date: Date())
            ] as [String: Any]

            messageCollection.addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message sent successfully")
                }
            }
        }
}
