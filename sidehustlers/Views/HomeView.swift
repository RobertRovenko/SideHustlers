//
//  HomeView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @ObservedObject var choreViewModel: ChoreViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Home Screen Content")
                List(choreViewModel.chores, id: \.id) { chore in
                    Text(chore.title)
                }

                Spacer()
            }
        }
        .onAppear {
            choreViewModel.fetchChores() 
        }
    }
}
