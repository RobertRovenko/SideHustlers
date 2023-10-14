//
//  Message.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-15.
//

import Foundation

struct Message: Identifiable {
    var id: String
    var sender: String
    var content: String
    var timestamp: Date // You can use a Date for the message timestamp

    init(id: String, sender: String, content: String, timestamp: Date) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }
}
