//
//  RewardsView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/12.
//

import SwiftUI

struct RewardsView: View {
    @StateObject private var viewModel = GoalViewModel()
    //print(min(Double(viewModel.progress)))
    //print(viewModel.rewards)

    var body: some View {
        VStack{
            HStack{
                Text("")
                Spacer()
                Text("ご褒美")
                    .fontWeight(.bold) // <- Change this line
                Spacer()
                Text("")
            }
            .padding()
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.2))
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.8))
            ScrollView {
                VStack {
                    ForEach(viewModel.rewards) { reward in
                        VStack(alignment: .leading) {
                            HStack{
                                Text(reward.name)
                            }
                            HStack{
                                Spacer()
                                Text("\(Double(viewModel.progress * 100) / Double(reward.progress) * 100)%")
                            }
                            ProgressView(value: min(Double(viewModel.progress * 100) / Double(reward.progress), 1.0))
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(.white)
                        .cornerRadius(24)
                        .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding()
                    }
                }
            }
            .onAppear {
                viewModel.fetchGoal() {
                    // 非同期処理が終わった後に実行される処理をここに記述します
                    // 例えば、データのロードが終わったらUIを更新する等
                }
            }
            .background(Color(red: 0.99, green: 0.99, blue: 0.99, opacity: 1.0))
        }
    }
}


struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}

