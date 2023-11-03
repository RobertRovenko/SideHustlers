//
//  PostView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import Firebase
import FirebaseAuth
import MapKit

struct PostView: View {
    @Binding var selectedTab: Int
    @State private var chore = Chore(id: "", title: "", description: "", reward: 0, createdBy: "", author: "", location: (latitude: 59.3293, longitude: 18.0686))
    @EnvironmentObject var choreViewModel: ChoreViewModel
    @State private var showAlert = false
    @State private var selectedCity = "Stockholm"
    
    let textFieldStyle: some TextFieldStyle = RoundedTextFieldStyle()
    
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
                                .textFieldStyle(textFieldStyle)
                            
                            TextField("Description", text: $chore.description)
                                .padding()
                                .textFieldStyle(textFieldStyle)
                            
                            Section(header:
                                    Text("Reward")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                            ) {
                                
                                
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
                                .padding()
                                .textFieldStyle(textFieldStyle)
                            }
                        }
                        
                        Section(header:
                            Text("Select City")
                                .font(.headline)
                                .foregroundColor(.blue)
                        ) {
                            Picker("City", selection: $selectedCity) {
                                ForEach(["Stockholm", "Uppsala", "Malmö", "Skåne", "Göteborg", "Helsingborg", "Other"], id: \.self) { city in
                                    Text(city)
                                        .tag(city)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 150)
                            .onAppear {
                                chore.location = getCoordinatesForCity(selectedCity)
                            }
                        }
                        
                        Section {
                            Button(action: {
                                if !fieldsAreEmpty {
                                    if let userEmail = currentUserEmail, let userUID = Auth.auth().currentUser?.uid {
                                        chore.createdBy = userEmail
                                        chore.author = userUID
                                        chore.location = getCoordinatesForCity(selectedCity)
                                        choreViewModel.addChore(chore: chore, createdBy: userEmail) { documentID in
                                            if let documentID = documentID {
                                                chore.id = documentID
                                                showAlert = true
                                                clearFields()
                                                }
                                            }
                                    } else {
                                        // Handle the case where the user or UID is not available
                                    }
                                } else {
                                    // Handle the case where the fields are empty
                                }
                            }) {
                                Text("Post Task")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }.padding()
                        }
                    }
                    .background(Color.white)
                }
                .padding()
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
    }
    
    func clearFields() {
        chore.title = ""
        chore.description = ""
        chore.reward = 0
    }
}

func getCoordinatesForCity(_ city: String) -> (Double, Double) {
    switch city {
        case "Stockholm":
            return (59.3293, 18.0686)
        case "Uppsala":
            return (59.8586, 17.6389)
        case "Malmö":
            return (55.6049, 13.0038)
        case "Skåne":
            return (55.9903, 13.5958)
        case "Göteborg":
            return (57.7089, 11.9746)
        case "Helsingborg":
            return (56.0465, 12.6945)
        default:
            return (59.3293, 18.0686)
    }
}



struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray6)))
    }
}
