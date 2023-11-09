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
                // Display a loading view while data is#imageLiteral(resourceName: "simulator_screenshot_54C2BA91-46F1-4CE5-8D01-56B0B783DC15.png") loading
                ZStack {
                LoadingView()
                        .frame(width: 100, height: 100)  // ローディングビューのサイズを設定します。
                        .position(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.2) // ローディングビューを画面の中央に配置します。
                }
            } else if appState.hasPosts {
                    TopView()
                        .environmentObject(GoalViewModel())
//                SubscriptionView()
            } else {
                RootView()
                    .environmentObject(router)
                    .environmentObject(appState)
            }
        }
    }
}

