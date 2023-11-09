//
//  ChoreEditView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-11-01.
//

    import SwiftUI
    import Firebase

    struct ChoreEditView: View {
        @EnvironmentObject var choreViewModel: ChoreViewModel
        @State private var chore: Chore
        init(chore: Chore) {
             _chore = State(initialValue: chore)
             _titleText = State(initialValue: chore.title)
             _descriptionText = State(initialValue: chore.description)
             _rewardText = State(initialValue: String(chore.reward))
         }

         let titleMaxLength = 40
         let descriptionMaxLength = 140
         let rewardMaxLength = 6

         @State private var titleText: String
         @State private var descriptionText: String
         @State private var rewardText: String

         var titleBinding: Binding<String> {
             Binding(
                 get: { self.titleText },
                 set: {
                     self.titleText = String($0.prefix(titleMaxLength))
                     self.chore.title = self.titleText
                 }
             )
         }

         var descriptionBinding: Binding<String> {
             Binding(
                 get: { self.descriptionText },
                 set: {
                     self.descriptionText = String($0.prefix(descriptionMaxLength))
                     self.chore.description = self.descriptionText
                 }
             )
         }

         var rewardBinding: Binding<String> {
             Binding(
                 get: { self.rewardText },
                 set: {
                     self.rewardText = String($0.prefix(rewardMaxLength))
                     if let intValue = Int(self.rewardText) {
                         self.chore.reward = intValue
                     }
                 }
             )
         }
        var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                        VStack {
                            Section(header:
                                Text("Task Details")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            ) {
                                TextField("Title", text: titleBinding)
                                                               .padding()
                                                               .textFieldStyle(RoundedTextStyle())

                                                           Text("Description")
                                                               .font(.headline)
                                                               .foregroundColor(.blue)

                                                           GeometryReader { geometry in
                                                               TextEditor(text: descriptionBinding)
                                                                   .padding()
                                                                   .frame(height: geometry.size.height * 0.8)
                                                                   .scrollContentBackground(.hidden)
                                                                   .background(Color(UIColor.systemGray6))
                                                                   .cornerRadius(8)
                                                                   .padding()
                                                           }
                                                       }
                            Section(header:
                                                       Text("Reward")
                                                           .font(.headline)
                                                           .foregroundColor(.blue)
                                                   ) {
                                                       TextField("Reward", text: rewardBinding)
                                                           .padding()
                                                           .textFieldStyle(RoundedTextStyle())
                                                   }
                                               }
                        
                        Spacer()
                        
                        Section {
                            Button(action: {
                                choreViewModel.updateChore(chore: chore) { success in
                                       if success {
                                           // Handle successful update (e.g., show an alert)
                                       } else {
                                           // Handle update failure (e.g., show an error message)
                                       }
                                   }
                            }) {
                                Text("Update Task")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }.padding()
                        }
                    }
                    .padding()
                    .navigationBarItems(trailing: Button(action: {
                        choreViewModel.deleteChore(chore: chore)
                               }) {
                                   Image(systemName: "trash")
                                    .foregroundColor(.red)
                               })
                }
            }
        }
    }
    struct RoundedTextStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray6)))
        }
    }
