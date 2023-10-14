//
//  Chores.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation

import Foundation

struct Chore: Identifiable, Encodable {
    var id: String
    var title: String
    var description: String
    var reward: Int
    var createdBy: String
   
    init(title: String, description: String, reward: Int, createdBy: String) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.reward = reward
        self.createdBy = createdBy
    }
}
