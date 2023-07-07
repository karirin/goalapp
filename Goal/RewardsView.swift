//
//  RewardsView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/12.
//

import SwiftUI

struct RewardsView: View {
    @StateObject private var viewModel = GoalViewModel()
    //let totalProgress = viewModel.calculateRewardProgressRate()
    @State private var rewardProgressRate: Double = 0.0


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
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            .foregroundColor(.white)
            .frame(height:30)
            ScrollView {
                VStack {
                    //Text("全体の進捗: \(totalProgress * 100)%")
                    ForEach(viewModel.rewards) { reward in
                        HStack{
                            Image(systemName: "gift.circle")
                                .foregroundColor(Color(red: 1, green: 0.2, blue: 0.2, opacity: 1))
                            Text("\(reward.progress)%達成")
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.top)
                        .font(.system(size: 30))
                        VStack(alignment: .leading) {
                            HStack{
                                Text(reward.name)
                                Spacer()
                                Text("残り\(100-reward.progressRate(for: viewModel.intermediateGoals))%")
                            }
                            .font(.system(size: 30))
                            HStack{
                                Spacer()
                            }
                            ProgressView(value: min(Double(viewModel.progress * 100) / Double(reward.progress), 1.0))
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100)
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
                    rewardProgressRate = viewModel.calculateRewardProgressRate()
                    print("Reward progress rate: \(rewardProgressRate)%")
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

