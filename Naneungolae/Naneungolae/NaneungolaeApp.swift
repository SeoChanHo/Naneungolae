//
//  NaneungolaeApp.swift
//  Naneungolae
//
//  Created by 서찬호 on 2023/04/04.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        return true
    }
}

@main
struct NaneungolaeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthStore())
                .environmentObject(UserStore())
                .environmentObject(FeedStore())
        }
    }
}
