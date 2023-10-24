//
//  FinderView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import FirebaseAuth

struct TasksView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var choreViewModel: ChoreViewModel

    @State private var userUID = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Your Listings")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding()

                List {
                    ForEach(choreViewModel.chores.filter { $0.author == userUID }) { chore in
                        ChoreRowView(chore: chore)
                    }
                }
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                userUID = user.uid
                print("User UID: \(userUID)") 
            }
        }
    }
}

struct ChoreRowView: View {
    var chore: Chore

    var body: some View {
        VStack(alignment: .leading) {
            Text(chore.title)
                .font(.headline)
            Text(chore.description)
                .font(.subheadline)
            Text("Reward: \(chore.reward)")
                .font(.subheadline)
        }
    }
}
