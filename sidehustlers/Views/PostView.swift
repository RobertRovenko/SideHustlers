//
//  PostView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct PostView: View {
    @Binding var selectedTab: Int
    @State private var chore = Chore(title: "", description: "", reward: 0, createdBy: "")
    @EnvironmentObject var choreViewModel: ChoreViewModel
    @State private var showAlert = false
    

    var fieldsAreEmpty: Bool {
        return chore.title.isEmpty || chore.description.isEmpty || chore.reward == 0
    }

    var currentUserEmail: String? {
        if let user = Auth.auth().currentUser {
            return user.email
        }
        return nil
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Task Details")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding()

                Form {
                    Section(header: Text("Task Details")) {
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
                            if !fieldsAreEmpty {
                                if let userEmail = currentUserEmail {
                                    
                                    chore.createdBy = userEmail
                                    choreViewModel.addChore(chore: chore, createdBy: userEmail)
                                    showAlert = true
                                    clearFields()
                                } else {
                                    
                                }
                            } else {
                                
                            }
                        }) {
                            Text("Post Task")
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Task posted successfully."),
                    dismissButton: .default(Text("OK")) {
                        
                    }
                )
            }
        }
    }
    func clearFields() {
        chore.title = ""
        chore.description = ""
        chore.reward = 0
    }
}
