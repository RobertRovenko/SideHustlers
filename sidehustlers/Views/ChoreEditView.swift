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
                            TextField("Title", text: $chore.title)
                                .padding()
                                .textFieldStyle(RoundedTextStyle())
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.blue)
                           
                            TextEditor(text: $chore.description)
                                .padding()
                                .frame(height: 200)
                                .scrollContentBackground(.hidden)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .padding()
                               
                        }
                        
                        Section(header:
                            Text("Reward")
                                .font(.headline)
                                .foregroundColor(.blue)
                        ) {
                            TextField("Reward", value: $chore.reward, formatter: NumberFormatter())
                                .padding()
                                .textFieldStyle(RoundedTextStyle())
                        }
                    }
                    
                    Spacer()
                    
                    Section {
                        Button(action: {
                            // Add chore logic here
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
                    
                               // Add code to handle the "Trash" action
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