//
//  ChoreViewModel.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChoreViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var chores: [Chore] = []

    init() {
        fetchChores()
    }

    func addChore(chore: Chore, createdBy: String, completion: @escaping (String?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let choreData = try encoder.encode(chore)

            let choreDictionary: [String: Any] = [
                "title": chore.title,
                "description": chore.description,
                "reward": chore.reward,
                "createdBy": createdBy,
                "author": chore.author,
                "locationData": [ // Include location data here
                    "latitude": chore.location.latitude,
                    "longitude": chore.location.longitude
                ]
            ]

            let documentReference = try db.collection("chores").addDocument(data: choreDictionary)

            let documentID = documentReference.documentID
            completion(documentID) // Provide the Firestore document ID in the completion handler
        } catch {
            print("Error adding chore: \(error)")
            completion(nil)
        }
    }

    func updateChore(chore: Chore, completion: @escaping (Bool) -> Void) {
        do {
            let encoder = JSONEncoder()
            let choreData = try encoder.encode(chore)

            let choreDictionary: [String: Any] = [
                "title": chore.title,
                "description": chore.description,
                "reward": chore.reward,
                "createdBy": chore.createdBy,
                "author": chore.author,
                "locationData": [ // Include location data here
                    "latitude": chore.location.latitude,
                    "longitude": chore.location.longitude
                ]
            ]

            db.collection("chores").document(chore.id).setData(choreDictionary, merge: true) { error in
                if let error = error {
                    print("Error updating chore: \(error)")
                    completion(false)
                } else {
                    print("Chore updated successfully")
                    completion(true)
                }
            }
        } catch {
            print("Error updating chore: \(error)")
            completion(false)
        }
    }

    func deleteChore(chore: Chore) {
        db.collection("chores").document(chore.id).delete { error in
            if let error = error {
                print("Error deleting chore: \(error)")
            } else {
                print("Chore deleted successfully")
            }
        }
    }

    func fetchChores() {
        db.collection("chores").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting chores: \(error)")
                return
            }

            var fetchedChores: [Chore] = []

            for document in querySnapshot!.documents {
                if let choreData = document.data() as? [String: Any],
                   let title = choreData["title"] as? String,
                   let description = choreData["description"] as? String,
                   let reward = choreData["reward"] as? Int,
                   let createdBy = choreData["createdBy"] as? String,
                   let author = choreData["author"] as? String,
                   let locationData = choreData["locationData"] as? [String: Double], // Change "location" to "locationData"
                   let latitude = locationData["latitude"],
                   let longitude = locationData["longitude"] {

                    let firestoreDocumentID = document.documentID

                    let chore = Chore(id: firestoreDocumentID, title: title, description: description, reward: reward, createdBy: createdBy, author: author, location: (latitude: latitude, longitude: longitude))
                    fetchedChores.append(chore)
                }
            }

            self.chores = fetchedChores
            print("Fetched \(fetchedChores.count) chores ViewModel")
            print("Chores: \(fetchedChores)")
        }
    }

    func fetchChoresForUser(userUID: String) {
        self.db.collection("chores")
            .whereField("author", isEqualTo: userUID)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting chores: \(error)")
                    return
                }

                var fetchedChores: [Chore] = []

                for document in querySnapshot!.documents {
                    if let choreData = document.data() as? [String: Any],
                       let title = choreData["title"] as? String,
                       let description = choreData["description"] as? String,
                       let reward = choreData["reward"] as? Int,
                       let createdBy = choreData["createdBy"] as? String,
                       let author = choreData["author"] as? String,
                       let locationData = choreData["location"] as? [String: Double],
                       let latitude = locationData["latitude"],
                       let longitude = locationData["longitude"] {

                        let firestoreDocumentID = document.documentID

                        let chore = Chore(id: firestoreDocumentID, title: title, description: description, reward: reward, createdBy: createdBy, author: author, location: (latitude: latitude, longitude: longitude))
                        fetchedChores.append(chore)
                    }
                }

                self.chores = fetchedChores
                print("Fetched Chores for user \(userUID): \(fetchedChores)")
            }
    }
}
