//
//  MessagesManager.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-20.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MessageManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var contacts: [String: String] = [:] // Maps email to UID
    @Published var uniqueSenderUIDs: [String] = [] // Store unique sender UIDs
    @Published var uniqueContactedSenderUIDs: [String] = [] // Store unique sender UIDs
    static let shared = MessageManager()
    
    // Load messages and contacts from Firebase
    func loadMessagesAndContacts() {
            // Fetch messages
            let messagesCollection = Firestore.firestore().collection("messages")
            messagesCollection.getDocuments { [self] (snapshot, error) in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                self.messages = documents.compactMap { document in
                    if let message = Message(document: document) {
                        return message
                    } else {
                        return nil
                    }
                }

                self.updateUniqueSenderUIDs()
                self.objectWillChange.send() // Notify the view to update
            }

            // Fetch user data to create contacts
            let usersCollection = Firestore.firestore().collection("users")
            usersCollection.getDocuments { [self] (snapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                self.contacts = Dictionary(uniqueKeysWithValues: documents.compactMap { document in
                    if let userData = UserData(document: document) {
                        return (userData.email, userData.uid)
                    } else {
                        return nil
                    }
                })

                self.objectWillChange.send() // Notify the view to update
            }
        }

    // Delete a contact based on the senderUID
    func deleteChat(senderUID: String) {
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            
            // Filter messages sent from the senderUID
            let messagesToDelete = messages.filter { message in
                return (message.senderUID == senderUID && message.receiverUID == currentUserUID) ||
                       (message.senderUID == currentUserUID && message.receiverUID == senderUID)
            }
            
            // Delete messages from Firebase Firestore
            let messagesCollection = Firestore.firestore().collection("messages")
            messagesToDelete.forEach { message in
                messagesCollection.document(message.id).delete { error in
                    if let error = error {
                        print("Error deleting message: \(error.localizedDescription)")
                    }
                }
            }
            
            // Update the messages array by removing deleted messages
            messages.removeAll { message in
                return messagesToDelete.contains { $0.id == message.id }
            }
            
            // Remove the senderUID from the uniqueContactedSenderUIDs
            uniqueContactedSenderUIDs = uniqueContactedSenderUIDs.filter { $0 != senderUID }
        }

    // Update the list of unique sender UIDs
    private func updateUniqueSenderUIDs() {
        let senderUIDs = messages.map { $0.senderUID }
        uniqueSenderUIDs = Array(Set(senderUIDs))
    }

    func fetchContactedUsers() {
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
        let contactedSenderUIDs = Set(messages.filter { $0.receiverUID == currentUserUID }.map { $0.senderUID })
        uniqueContactedSenderUIDs = Array(contactedSenderUIDs)
    }
}

struct UserData {
    let uid: String
    let email: String
    // Add other properties to match your Firestore data
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let uid = data["uid"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        self.uid = uid
        self.email = email
        // Initialize other properties as needed
    }
}
