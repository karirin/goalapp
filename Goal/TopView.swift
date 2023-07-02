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
    @StateObject var viewModel = GoalViewModel()
    @State private var selectedTab = 0  // <- Add this line
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {  // <- Add "selection: $selectedTab"
                ContentView()
                    .tag(0)  // <- Add this line
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                CalendarTestView()
                    .tag(1)  // <- Add this line
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                ChartView()
                    .tag(2)  // <- Add this line
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("グラフ")
                    }
                RewardsView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "gift")
                        Text("ご褒美")
                    }
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

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
