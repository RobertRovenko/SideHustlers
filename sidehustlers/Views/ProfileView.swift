//
//  ProfileView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @Binding var selectedTab: Int
    @Binding var isAuthViewPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Log Out") {
                    do {
                        try Auth.auth().signOut()
                      
                        isAuthViewPresented = true
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}
