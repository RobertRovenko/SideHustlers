//
//  sidehustlersApp.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct sidehustlersApp: App {
    
    @StateObject private var choreViewModel = ChoreViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(choreViewModel)
        }
    }
}
