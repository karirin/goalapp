//
//  TopView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/10.
//

import SwiftUI
import FirebaseDatabase
import UIKit
import StoreKit

struct TopView: View {
    @EnvironmentObject private var viewModel: GoalViewModel
    @State private var selectedTab = 0  // <- Add this line
    @StateObject var router = NavigationRouter()
    @StateObject var appState = AppState()
    @State private var showingNotificationView = false

    
    var body: some View {
        if viewModel.showRootView {
            RootView()
                .environmentObject(router)
                .environmentObject(appState)
        } else {
            VStack {
                TabView(selection: $selectedTab) {  // <- Add "selection: $selectedTab"
//                    ZStack {
                        ContentView()
                            .environmentObject(viewModel)
                            .tag(0) 
                        .tabItem {
                            Image(systemName: "house")
                            Text("ホーム")
                        }
                    
//                    ZStack {
                        CalendarTestView()
                            .tag(1)  // <- Add this line
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView2()
//                                    .padding(.trailing, 10)
//                                    .padding(.top,10)
//                            }
//                            Spacer()
//                        }
//                    }
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("カレンダー")
                        }
//                    }
//                    ZStack {
                        ChartView()
                            .tag(2)  // <- Add this line
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView3()
//                                    .padding(.trailing, 10)
//                                    .padding(.top,10)
//                            }
//                            Spacer()
//                        }
                        .tabItem {
                            Image(systemName: "chart.xyaxis.line")
                            Text("グラフ")
                        }
//                    }
//                    ZStack {
                        RewardsView()
                            .tag(3)
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView4()
//                                    .padding(.trailing, 10)
//                                    .padding(.top,10)
//                            }
//                            Spacer()
//                        }
                        .tabItem {
                            Image(systemName: "gift")
                            Text("ご褒美")
                        }
                    SubscriptionView()
                        .tag(4)
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView4()
//                                    .padding(.trailing, 10)
//                                    .padding(.top,10)
//                            }
//                            Spacer()
//                        }
                    .tabItem {
                        Image(systemName: "lane")
                        Text("サブスクリプション")
                    }
//                    }
                    SettingsView()
                        .tag(5)
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
            }
        }
    }
}

func promptForReview() {
    let launchCount = UserDefaults.standard.integer(forKey: "launchCount") + 1
    UserDefaults.standard.set(launchCount, forKey: "launchCount")
    
    if launchCount % 5 == 0 {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(GoalViewModel())
    }
}
