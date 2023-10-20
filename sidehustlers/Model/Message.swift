//
//  Message.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-15.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct Message: Identifiable {
    var id: String // Add an 'id' property to conform to Identifiable
    let senderUID: String
    let receiverUID: String
    let content: String
    let timestamp: Date

    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let senderUID = data["sender"] as? String,
              let receiverUID = data["receiver"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }

        self.id = document.documentID // Use Firestore document ID as the message's unique identifier
        self.senderUID = senderUID
        self.receiverUID = receiverUID
        self.content = content
        self.timestamp = timestamp.dateValue()
    }
}
