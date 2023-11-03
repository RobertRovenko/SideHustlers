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
            var choreDictionary = try JSONSerialization.jsonObject(with: choreData, options: []) as! [String: Any]

            choreDictionary["createdBy"] = createdBy
            choreDictionary["author"] = chore.author

            let documentReference = try db.collection("chores").addDocument(data: choreDictionary)

            let documentID = documentReference.documentID
            completion(documentID) // Provide the Firestore document ID in the completion handler
        } catch {
            print("Error adding chore: \(error)")
            completion(nil)
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
                if let choreData = document.data() as? [String: Any] {
                    if let title = choreData["title"] as? String,
                       let description = choreData["description"] as? String,
                       let reward = choreData["reward"] as? Int,
                       let createdBy = choreData["createdBy"] as? String,
                       let author = choreData["author"] as? String {
                       
                        let firestoreDocumentID = document.documentID // Get the Firestore document ID

                        let chore = Chore(id: firestoreDocumentID, title: title, description: description, reward: reward, createdBy: createdBy, author: author)
                        fetchedChores.append(chore)
                    }
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
                    if let choreData = document.data() as? [String: Any] {
                        if let title = choreData["title"] as? String,
                           let description = choreData["description"] as? String,
                           let reward = choreData["reward"] as? Int,
                           let createdBy = choreData["createdBy"] as? String,
                           let author = choreData["author"] as? String {
                           
                            let firestoreDocumentID = document.documentID // Get the Firestore document ID

                            let chore = Chore(id: firestoreDocumentID, title: title, description: description, reward: reward, createdBy: createdBy, author: author)
                            fetchedChores.append(chore)
                        }
                    }
                }

                self.chores = fetchedChores
                print("Fetched Chores for user \(userUID): \(fetchedChores)")
            }
    }

}
