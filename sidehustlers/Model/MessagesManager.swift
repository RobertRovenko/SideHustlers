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
    @Published var contacts: [String: String] = [:]
    @Published var uniqueSenderUIDs: [String] = []
    @Published var uniqueContactedSenderUIDs: [String] = []
    static let shared = MessageManager()
    
    func loadMessagesAndContacts() {
        let messagesCollection = Firestore.firestore().collection("messages")
        let messagesListener = messagesCollection.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
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
            self.objectWillChange.send()
        }
        
        // Store the messagesListener somewhere if you need to remove it later.
        
        let usersCollection = Firestore.firestore().collection("users")
           let usersListener = usersCollection.addSnapshotListener { [weak self] (snapshot, error) in
               guard let self = self else { return }

               if let error = error {
                   print("Error fetching users: \(error.localizedDescription)")
                   return
               }

               guard let documents = snapshot?.documents else { return }

               var tempContacts: [String: [String]] = [:]

               for document in documents {
                   if let userData = UserData(document: document) {
                       let email = userData.email
                       let uid = userData.uid

                       // Check if the email is already in the dictionary
                       if var existingUIDs = tempContacts[email] {
                           existingUIDs.append(uid)
                           tempContacts[email] = existingUIDs
                       } else {
                           // If the email is not in the dictionary, create a new entry
                           tempContacts[email] = [uid]
                       }
                   }
               }

               // Now convert the temporary dictionary to the final dictionary
               self.contacts = tempContacts.mapValues { $0.first ?? "" }

               self.objectWillChange.send()
           }
        // Store the usersListener somewhere if you need to remove it later.
    }

    
    private func updateUniqueSenderUIDs() {
           let senderUIDs = messages.map { $0.senderUID }
           uniqueSenderUIDs = Array(Set(senderUIDs))
       }
    
    func fetchContactedUsers() {
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""

        let contactedSenderUIDs = Set(messages
            .filter { $0.senderUID == currentUserUID }
            .map { $0.receiverUID }
        )

        uniqueContactedSenderUIDs = Array(contactedSenderUIDs)
    }

    func updateContactedUIDs() {
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            
            let contactedSenderUIDs = Set(messages.filter { $0.receiverUID == currentUserUID }.map { $0.senderUID })
            uniqueContactedSenderUIDs = Array(contactedSenderUIDs)
        }

        var combinedContactedUIDs: [String] {
            return Array(Set(uniqueContactedSenderUIDs + uniqueSenderUIDs))
        }

}

struct UserData {
    let uid: String
    let email: String
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let uid = data["uid"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        self.uid = uid
        self.email = email
      
    }
}
