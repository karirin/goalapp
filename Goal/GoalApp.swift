//
//  GoalApp.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleMobileAds
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @StateObject var appState = AppState()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        DispatchQueue.global(qos: .background).async {
            self.checkSubscription()
        }
        return true
     }
    
    func checkSubscription() {
        Task {
            do {
                let subscribed = try await self.isSubscribed()
                DispatchQueue.main.async {
                    self.appState.isBannerVisible = !subscribed
                }
            } catch {
                print("サブスクリプションの確認中にエラー: \(error)")
            }
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .unverified(_, verificationError):
            throw verificationError
        case let .verified(safe):
            return safe
        }
    }

    func getSubscriptionRenewalState(groupID: String) async throws -> [StoreKit.Product.SubscriptionInfo.RenewalState] {
      var results: [StoreKit.Product.SubscriptionInfo.RenewalState] = []
      
      let statuses = try await Product.SubscriptionInfo.status(for: groupID)
      for status in statuses {
        guard case .verified(let renewalInfo) = status.renewalInfo,
              case .verified(let transaction) = status.transaction
        else {
          continue
        }
        results.append(status.state)
      }
      return results
    }
      
    func isSubscribed() async throws -> Bool {
        var subscriptionGroupIds: [String] = []
        for await result in Transaction.currentEntitlements {
            let transaction = try self.checkVerified(result)
            guard let groupId = transaction.subscriptionGroupID else { continue }
            subscriptionGroupIds.append(groupId)
        }

        for groupId in subscriptionGroupIds {
            let renewalStates = try await getSubscriptionRenewalState(groupID: groupId)
            for state in renewalStates {
                switch state {
                case .subscribed, .inGracePeriod:
                    return true
                default:
                    break
                }
            }
        }
        
        return false // サブスクリプションがない、または有効でない場合に false を返す
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
                if appState.isBannerVisible {
                    BannerView()
                        .frame(height: 60)
                }
                    TopView()
                        .environmentObject(GoalViewModel())
                        .environmentObject(appState)
//                SubscriptionView()
            } else {
                RootView()
                    .environmentObject(router)
                    .environmentObject(appState)
            }
        }
    }
}

