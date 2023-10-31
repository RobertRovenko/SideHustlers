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
            self.objectWillChange.send()
        }
        
        
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
            
            self.objectWillChange.send()
        }
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
