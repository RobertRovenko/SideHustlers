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
    @ObservedObject var messageManager: MessageManager
    @State private var selectedChore: Chore?
    @Binding var contacts: [String]
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
                                onContactMakerTapped: { contactEmail in
                                    contacts.append(chore.id)
                                }, messageManager: messageManager
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
            messageManager.loadMessagesAndContacts()
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
                }, messageManager: messageManager),
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
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(10)
                .shadow(radius: 5)
            
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
                    messageManager.loadMessagesAndContacts()
                    messageManager.fetchContactedUsers()
                }
            }
        
    
    
    func sendMessage(to receiverUID: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated")
            return
        }
        
        // Check if the senderUID is different from the receiverUID
        if currentUser.uid != receiverUID {
            let messageContent = "Hej, jag är intresserad av din annons - \(chore.title)"
            
            let db = Firestore.firestore()
            let messageCollection = db.collection("messages")

            let messageData = [
                "sender": currentUser.uid,
                "receiver": receiverUID,
                "content": messageContent,
                "timestamp": Timestamp(date: Date())
            ] as [String: Any]

            messageCollection.addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message sent successfully")
                   
                   
                    messageManager.loadMessagesAndContacts()
                    messageManager.fetchContactedUsers()
                }
            }
        }
    }
}

struct MapView: UIViewRepresentable {
   
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
       
        let coordinate = CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        uiView.setRegion(region, animated: true)
    }
}
