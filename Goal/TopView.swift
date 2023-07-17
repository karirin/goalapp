//
//  TopView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/10.
//

import SwiftUI
import FirebaseDatabase
import UIKit

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
                    ZStack {
                        ContentView()
                            .environmentObject(viewModel)
                            .tag(0)  // <- Add this line
                        VStack {
                            HStack {
                                Spacer()
                                HelpView1()
                                    .padding(.trailing, 15)
//                                    .padding(.top)
                            }
                            Spacer()
                        }
                    }
                        .tabItem {
                            Image(systemName: "house")
                            Text("ホーム")
                        }
                    
                    ZStack {
                        CalendarTestView()
                            .tag(1)  // <- Add this line
                        VStack {
                            HStack {
                                Spacer()
                                HelpView2()
                                    .padding(.trailing, 10)
                                    .padding(.top,10)
                            }
                            Spacer()
                        }
                    }
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
//                    }
                    SettingsView()
                        .tag(4)
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
            }
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
            .environmentObject(GoalViewModel())
    }
}
