//
//  ContentView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI

struct ProgressRingView: View {
    var progress: Double
    var goal: String
    var intermediate_goals: [GoalViewModel.IntermediateGoal]
    var updateProgressInFirebase: (Int, Int, Date) -> Void

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .padding()
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .padding()
                
                VStack {
                    Text(goal)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(Int(progress * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
            
            TabView {
                ForEach(0..<intermediate_goals.count, id: \.self) { index in
                    let intermediate_goal = intermediate_goals[index]
                    VStack {
                        Text(intermediate_goal.goal)
                            .font(.title)
                            .fontWeight(.bold)
                        HStack {
                            Button(action: {
                                let currentDate = Date()  // Get current date
                                updateProgressInFirebase(index, intermediate_goal.progress - 1, currentDate)
                            }) {
                                Image(systemName: "minus.circle")
                            }
                            Text("\(intermediate_goal.progress)")
                            Button(action: {
                                let currentDate = Date()  // Get current date
                                updateProgressInFirebase(index, intermediate_goal.progress + 1, currentDate)
                            }) {
                                Image(systemName: "plus.circle")
                            }
                            Text(" / ")
                            Text("\(intermediate_goal.value)")
                            Text(intermediate_goal.unit)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = GoalViewModel()

    var body: some View {
        Group {
            if viewModel.dataFetched {
                //Text("\(viewModel.dataFetched)")
        ProgressRingView(
            progress: viewModel.progress,
            goal: viewModel.goal,
            intermediate_goals: viewModel.intermediateGoals,  // Change this line
            updateProgressInFirebase: { index, newProgress, date in
                viewModel.updateIntermediateProgress(index, newProgress, date)
            }
        )
            } else {
                // Display a loading indicator or placeholder here
                Text("Loading...")
            }
        }
            .onAppear {
                viewModel.fetchGoal()
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
