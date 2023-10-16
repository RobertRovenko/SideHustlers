//
//  ContactViewModel.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-15.
//

import Foundation
class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []

    // Function to fetch user-specific contacts
    func fetchContactsForUser() {
        //Implement the code to fetch contacts for the current user using their UID
        //Update the `contacts` array with the fetched data
    }

    // Function to add a contact for the user
    func addContactForUser(contactName: String) {
        //Implement the code to add a contact for the current user using their UID
        //Update the `contacts` array with the new contact
    }
}
