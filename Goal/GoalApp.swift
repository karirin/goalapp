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
      if FirebaseApp.app() == nil {
          FirebaseApp.configure()
      }
      return true
  }
}

@main
struct GoalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var router = NavigationRouter()
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoading {
                // Display a loading view while data is loading
                LoadingView(3)
            } else if appState.hasPosts {
                // If there are posts, display the TopView
                TopView()
                    .environmentObject(GoalViewModel())
            } else {
                // If there are no posts, display the PostView
                RootView()
                    .environmentObject(router)
                    .environmentObject(appState)
            }
        }
    }
}

