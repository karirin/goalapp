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
    var body: some View {
        VStack {
                TabView {
                    ZStack {
                        ContentView()
//                            .background(Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 1.0))
                        
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView()
//                                    .padding(.trailing, 10)
//                            }
//                            Spacer()
//                        }
                    }
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                    
                    ZStack {
                        CalendarTestView()
//                            .background(Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 1.0))
                        
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView()
//                                    .padding(.trailing, 10)
//                            }
//                            Spacer()
//                        }
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                    
//                    ZStack {
//                        PieView()
//                            .background(Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 1.0))
                        
//                        VStack {
//                            HStack {
//                                Spacer()
//                                HelpView()
//                                    .padding(.trailing, 10)
//                            }
//                            Spacer()
//                        }
//                    }
//                    .tabItem {
//                        Image(systemName: "chart.xyaxis.line")
//                        Text("グラフ")
//                    }
                    
                    SettingsView()
//                        .background(Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 1.0))
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("設定")
                        }
                }
        }
    }

    fileprivate struct AnotherView: View {
        
        var textContent: String
        
        var body: some View {
            
            Text(textContent)
            
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
