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
    @State private var chatViews: [String: [Message]] = [:]

    var body: some View {
        NavigationView {
            VStack {
                if chatViews.isEmpty {
                    Text("You have no messages!")
                } else {
                    Text("Messages")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                    List {
                        ForEach(chatViews.sorted(by: { $0.value.last?.timestamp ?? .distantPast > $1.value.last?.timestamp ?? .distantPast }), id: \.key) { (uid, messages) in
                            if let contactEmail = messageManager.contacts.first(where: { $0.value == uid })?.key {
                                NavigationLink(destination: ChatView(contactEmail: contactEmail, receiverUID: uid, messageManager: messageManager)) {
                                    HStack {
                                        Text(contactEmail)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("Today")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 10)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 10)
                                    .listRowInsets(EdgeInsets())
                                }
                                .swipeActions {
                                    Button("Delete", role: .destructive) {
                                        // Delete the chat or perform your desired action
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            messageManager.fetchContactedUsers()
        }
        .onReceive(messageManager.$messages) { newMessages in
            updateChatViews(messages: newMessages)
        }
    }

    private func updateChatViews(messages: [Message]) {
        chatViews.removeAll()

        for message in messages {
            let uid = message.senderUID == Auth.auth().currentUser?.uid ? message.receiverUID : message.senderUID

            if chatViews[uid] == nil {
                chatViews[uid] = [message]
            } else {
                chatViews[uid]?.append(message)
            }
        }
    }
}


struct ChatView: View {
    @State private var newMessage = ""
    let contactEmail: String
    let receiverUID: String
    @ObservedObject var messageManager: MessageManager
    let senderUID = Auth.auth().currentUser!.uid
   
    var body: some View {
        VStack {
            List {
                ForEach(messageManager.messages.filter { message in
                                  return (message.senderUID == Auth.auth().currentUser?.uid && message.receiverUID == receiverUID) ||
                                         (message.senderUID == receiverUID && message.receiverUID == Auth.auth().currentUser?.uid)
                              }.sorted(by: { $0.timestamp < $1.timestamp })) { message in
                                  if message.senderUID == Auth.auth().currentUser?.uid {
        
                        HStack {
                            Spacer()
                            Text("\(message.content)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        }
                    }
                    
                    else {
                        HStack {
                            Text("\(message.content)")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.plain)
           
            
            .onAppear {
                messageManager.loadMessagesAndContacts()
            }

           
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.subheadline)
                    .padding()
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                Button(action: {
                    if !newMessage.isEmpty {
                        sendMessage(to: receiverUID, messageContent: newMessage)
                        newMessage = ""
                        messageManager.loadMessagesAndContacts()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.title)
                        .padding(.all, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .navigationBarTitle(contactEmail, displayMode: .inline)
        
    }
}

func sendMessage(to receiverUID: String, messageContent: String) {
    guard let currentUser = Auth.auth().currentUser else {
        print("User not authenticated")
        return
    }

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
