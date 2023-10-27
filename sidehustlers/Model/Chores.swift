//
//  Chores.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation

struct Chore: Identifiable, Encodable {
    var id: String
    var title: String
    var description: String
    var reward: Int
    var createdBy: String
    var author: String

    init(title: String, description: String, reward: Int, createdBy: String, author: String) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.reward = reward
        self.createdBy = createdBy
        self.author = author 
    }
}
