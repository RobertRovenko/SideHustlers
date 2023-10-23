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


struct MessagesView: View {
    @Binding var selectedTab: Int
    @ObservedObject var messageManager: MessageManager

    var body: some View {
        NavigationView {
            VStack {
                if messageManager.uniqueContactedSenderUIDs.isEmpty {
                    Text("You have no messages!")
                } else {
                    List {
                        ForEach(messageManager.uniqueContactedSenderUIDs, id: \.self) { senderUID in
                            if let contactEmail = messageManager.contacts.first(where: { $0.value == senderUID })?.key {
                                NavigationLink(destination: ChatView(contactEmail: contactEmail, messageManager: messageManager)) {
                                    Text(contactEmail)
                                }
                                .swipeActions {
                                    Button("Delete", role: .destructive) {
                                        messageManager.deleteChat(senderUID: senderUID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            messageManager.loadMessagesAndContacts()
            messageManager.fetchContactedUsers()
        }
    }
}

struct ChatView: View {
    let contactEmail: String
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        VStack {
            Text("Chat with \(contactEmail)")
            
           
            List {
                ForEach(messageManager.messages.filter { message in
                    (message.senderUID == Auth.auth().currentUser?.uid && message.receiverUID == messageManager.contacts[contactEmail]) ||
                    (message.senderUID == messageManager.contacts[contactEmail] && message.receiverUID == Auth.auth().currentUser?.uid)
                }) { message in
                    Text("\(message.content)")
                }
            }
            
          
        }
    }
}

