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
                RewardsView()
                    .tag(2)  // <- Add this line
                    .tabItem {
                        Image(systemName: "gift")
                        Text("ご褒美")
                    }
                ChartView()
                    .tag(3)  // <- Add this line
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("グラフ")
                    }
                SettingsView()
                    .tag(4)  // <- Add this line
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
            }
        }
    }
    
    var tabTitle: String {
        switch selectedTab {
        case 0: return "目標"
        case 1: return "カレンダー"
        case 2: return "ご褒美"
        default: return ""
        }
    }
}


struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
