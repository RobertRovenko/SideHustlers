//
//  HomeView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import MapKit

struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var choreViewModel: ChoreViewModel
    @State private var selectedChore: Chore?
    @Binding var contacts: [String]
    @StateObject var contactViewModel = ContactViewModel()
    
    @State private var isChoreDetailPresented = false
    @State private var choreDetailContact: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Image("SideHustlersIconSmall")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)

                HStack {
                    Text("Available Tasks")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()

                List {
                    ForEach(choreViewModel.chores, id: \.id) { chore in
                        NavigationLink(
                            destination: ChoreDetailView(
                                chore: chore,
                                selectedTab: $selectedTab,
                                contacts: $contacts,
                                onContactMakerTapped: { _ in
                                contacts.append(chore.id)
                            }
                        ))
                    {
                    VStack(alignment: .leading) {
                        Text(chore.title)
                        Text("Reward: \(chore.reward) kr")
                    }
                }
            }
        }
    }
            .onAppear {
            choreViewModel.fetchChores()
            }
        }
    }
                

    private func navigateToChoreDetail(chore: Chore) {
        NavigationLink(
            destination: ChoreDetailView(
                chore: chore,
                selectedTab: $selectedTab,
                contacts: $contacts,
                onContactMakerTapped: { _ in
                contacts.append(chore.id)
            }),
            label: {
                EmptyView()
            })
        }
    }

struct ChoreDetailView: View {
    let chore: Chore
    @Binding var selectedTab: Int
    @Binding var contacts: [String]
    var onContactMakerTapped: (String) -> Void
    
    var body: some View {
        ZStack {
            Color.white // Background color for the card
                .cornerRadius(10)
                .shadow(radius: 5) // Apply a shadow to create the card-like appearance
            
            VStack {
                MapView()
                    .frame(height: 200)
                    .padding()
                
                VStack {
                    Text(chore.title)
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(chore.description)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)

                    
                    Spacer()
                    
                    Text("\(chore.reward) kr")
                        .padding()
                    
                    Button(action: {
                        addContactToFirebase(chore.createdBy)
                    }) {
                        Text("Contact Maker")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .padding()
    
        .navigationBarTitle(chore.title, displayMode: .inline)
     
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               
            }
        }
    }

  


    
    
    func addContactToFirebase(_ contactEmail: String) {
           
            let db = Firestore.firestore()

            db.collection("users").whereField("email", isEqualTo: contactEmail).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error looking up user: \(error.localizedDescription)")
                    return
                }

                guard let document = querySnapshot?.documents.first else {
                    print("User with email not found")
                    return
                }

                let contactUID = document.documentID
                
                sendMessage(to: contactUID)
            }
        }
    
    
    func sendMessage(to receiverUID: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }

        let contactEmail = currentUser.email ?? "Your email"
        let messageContent = "Hej, jag är intreserad av din annons - \(chore.title), om du vill kan du kontakta mig via \(contactEmail)."
        
        let db = Firestore.firestore()
        let messageCollection = db.collection("messages")

        let messageData = [
            "sender": currentUser.uid,
            "receiver": receiverUID,
            "content": messageContent,
            "timestamp": Timestamp(date: Date()) ] as [String: Any]

        messageCollection.addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
            }
        }
    }
}

struct MapView: UIViewRepresentable {
   
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the MapView here
        let coordinate = CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        uiView.setRegion(region, animated: true)
    }
}
