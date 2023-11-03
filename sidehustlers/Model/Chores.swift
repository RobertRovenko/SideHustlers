//
//  Chores.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation

struct Chore: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var reward: Int
    var createdBy: String
    var author: String
    var location: (latitude: Double, longitude: Double)

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case reward
        case createdBy
        case author
        case latitude
        case longitude
    }

    init(id: String, title: String, description: String, reward: Int, createdBy: String, author: String, location: (latitude: Double, longitude: Double)) {
        self.id = id
        self.title = title
        self.description = description
        self.reward = reward
        self.createdBy = createdBy
        self.author = author
        self.location = location
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        reward = try container.decode(Int.self, forKey: .reward)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        author = try container.decode(String.self, forKey: .author)

        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = (latitude: latitude, longitude: longitude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(reward, forKey: .reward)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(author, forKey: .author)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
    }
}
