//
//  ProfileView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI


struct ProfileView: View {
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Screen Content")
                //The content of your home screen here
                Spacer()
            }
        }
    }
}
