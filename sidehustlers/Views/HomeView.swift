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
                Image("SHIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                HStack {
                           Text("Available Tasks")
                               .frame(maxWidth: .infinity, alignment: .leading)
                           Spacer()
                       }
                       .padding()
                
                List(choreViewModel.chores, id: \.id) { chore in
                        VStack(alignment: .leading) {
                            Text(chore.title)
                            Text("Reward: \(chore.reward) kr")
                        }
                    }

                Spacer()
            }
        }
        .onAppear {
            choreViewModel.fetchChores() 
        }
    }
}
