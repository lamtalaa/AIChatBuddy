//
//  AppDelegate.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/16/25.
//

import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let clientID = "327354679505-kra7pikogd1k3gdktdeenkmqeuudm71q.apps.googleusercontent.com"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

