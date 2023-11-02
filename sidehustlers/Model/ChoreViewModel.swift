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

    func addChore(chore: Chore, createdBy: String) {
        do {
            let encoder = JSONEncoder()
            let choreData = try encoder.encode(chore)
            var choreDictionary = try JSONSerialization.jsonObject(with: choreData, options: []) as! [String: Any]
            
            choreDictionary["createdBy"] = createdBy
            choreDictionary["author"] = chore.author 
            
            _ = try db.collection("chores").addDocument(data: choreDictionary)
            
        } catch {
            print("Error adding chore: \(error)")
        }
    }

    func deleteChore(_ chore: Chore) {
        let choreRef = db.collection("chores").document(chore.id)
        choreRef.delete { error in
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
                       let chore = Chore(title: title, description: description, reward: reward, createdBy: createdBy, author: author)
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
                               let chore = Chore(title: title, description: description, reward: reward, createdBy: createdBy, author: author)
                               fetchedChores.append(chore)
                           }
                       }
                   }

                   self.chores = fetchedChores
                   
                   print("Fetched Chores for user \(userUID): \(fetchedChores)")
               }
       }
}
