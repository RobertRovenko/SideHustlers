//
//  FinderView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI

struct TasksView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Tasks")
                
                Spacer()
            }
        }
    }
}
