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
        ScrollView {

            VStack {
                    ForEach(viewModel.rewards) { reward in
                        VStack(alignment: .leading) {
                            HStack{
                                Text(reward.name)
                                Text("\(Double(viewModel.progress * 100) / Double(reward.progress) * 100)%")
                            }
                            ProgressView(value: min(Double(viewModel.progress * 100) / Double(reward.progress), 1.0))

                        }
                        .padding()

                    }
            }
        }
        .onAppear(perform: viewModel.fetchGoal)
    }
}


struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}

