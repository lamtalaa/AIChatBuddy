//
//  AIChatBuddyApp.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 5/28/25.
//

import SwiftUI
import FirebaseCore

@main
struct AIChatBuddyApp: App {
    
//    init() {
//        FirebaseApp.configure()
//    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
