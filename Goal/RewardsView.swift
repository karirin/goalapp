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
    @State private var showAlert: Bool = false

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
            .frame(height:50)
            .font(.system(size: 20))
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
                            VStack{
                                Text(reward.name)
                                HStack{
                                    Spacer()
                                    Text("残り\(max(100-reward.progressRate(for: viewModel.intermediateGoals), 0))%")
                                        .onChange(of: reward.progressRate(for: viewModel.intermediateGoals)) { newValue in
                                            if 100 - newValue <= 0 {
                                                showAlert = true
                                            }
                                        }
                                }
                            ProgressView(value: max(min(Double(viewModel.progress * 100) / Double(reward.progress), 1.0), 0.0))
                                .accentColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(.white)
                        .cornerRadius(24)
                        .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
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
        .alert(isPresented: $viewModel.showRewardAchievedAlert) {
            Alert(
                title: Text("達成！"),
                message: Text("ご褒美の進捗率が100%に達しました。おめでとうございます！"),
                dismissButton: .default(Text("OK")) {
                    viewModel.showRewardAchievedAlert = false  // Reset the state
                }
            )
        }
    }
}


struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}

