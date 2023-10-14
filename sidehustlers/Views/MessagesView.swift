//
//  MessagesView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI

struct MessagesTyperView: View {
    @Binding var selectedTab: Int
    let contact: String
    @State private var newMessage = ""
    @State private var messages: [Message] = []

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
    var currentContact: String
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MessagesTyperView(selectedTab: $selectedTab, contact: currentContact )) {
                    Text("Contact Name")
                }
              
            }
        }
    }
}
