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
    let messageManager = MessageManager.shared
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
    FirebaseApp.configure()
    messageManager.loadMessagesAndContacts()
    return true
        
  }
}


@main
struct sidehustlersApp: App {
    @StateObject private var messageManager = MessageManager.shared
    @StateObject private var choreViewModel = ChoreViewModel()
    @State private var isDarkThemeEnabled = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(choreViewModel)
                .environmentObject(messageManager)
                .environment(\.isDarkModeEnabled, $isDarkThemeEnabled)
        }
    }
}
