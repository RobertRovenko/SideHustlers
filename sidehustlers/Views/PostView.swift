//
//  PostView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI
import Firebase

struct PostView: View {
    @Binding var selectedTab: Int
    @State private var chore = Chore(title: "", description: "", reward: 0)
    @EnvironmentObject var choreViewModel: ChoreViewModel
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chore Details")) {
                    TextField("Title", text: $chore.title)
                    TextField("Description", text: $chore.description)
                    TextField("Reward", text: Binding(
                                           get: {
                                               "\(chore.reward)"
                                           },
                                           set: {
                                               if let newValue = Int($0) {
                                                   chore.reward = newValue
                                               }
                                           }
                                       ))
                }
                    Section {
                        Button(action: {
                            choreViewModel.addChore(chore: chore)
                            showAlert = true
                            clearFields()
                        }) {
                            Text("Post Chore")
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Chore posted successfully."),
                    dismissButton: .default(Text("OK")) {
                               
                }
            )
        }
    }
    func clearFields() {
           chore.title = ""
           chore.description = ""
            chore.reward = 0
       }
}
