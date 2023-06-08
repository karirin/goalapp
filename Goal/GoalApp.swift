//
//  GoalApp.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
      FirebaseApp.configure()
      return true
  }
}

@main
struct GoalApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            FirstPage()
        }
    }
}
