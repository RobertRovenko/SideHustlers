//
//  UserSettings.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-16.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    @Published var userEmail: String = "Welcome!"

    func updateEmail(_ email: String) {
        userEmail = email
    }
}
