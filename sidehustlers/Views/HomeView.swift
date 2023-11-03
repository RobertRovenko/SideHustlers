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
                    Text("Available Work")
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
                        HStack{
                          
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .frame(width: 45, height: 30)
                                .foregroundColor(.gray)
                            
                            Spacer().frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text(chore.title)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer().frame(height: 8)
                                
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.green)
                                    
                                    
                                    Text("Salary: \(chore.reward) kr")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
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
    @State private var isDetailViewActive = false
    
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(10)
                .shadow(radius: 5)
            
            VStack {
                MapView(coordinate: CLLocationCoordinate2D(latitude: chore.location.latitude, longitude: chore.location.longitude))
                    .frame(height: 200)
                   
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
                        selectedTab = 1
                        
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
        
        //Check if the senderUID is not the receiverUID
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
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
   
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        uiView.setRegion(region, animated: true)
    }
}
