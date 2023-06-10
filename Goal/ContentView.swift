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
    var intermediate_goal: String
    var intermediate_unit: String
    var intermediate_value: Int
    @Binding var intermediate_progress: Int
    var updateProgressInFirebase: () -> Void
    
    var body: some View {
        VStack{
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
            Text(intermediate_goal)
                .font(.title)
                .fontWeight(.bold)
            HStack{
                Button(action: {
                    self.intermediate_progress -= 1
                    self.updateProgressInFirebase()
                }) {
                    Image(systemName: "minus.circle")
                }
                Text("\(intermediate_progress)")
                Button(action: {
                    self.intermediate_progress += 1
                    self.updateProgressInFirebase()
                }) {
                    Image(systemName: "plus.circle")
                }
                Text(" / ")
                Text("\(intermediate_value)")
                Text(intermediate_unit)
            }
        }
        
    }
}

struct ContentView: View {
    @StateObject private var viewModel = GoalViewModel()

    var body: some View {
        ProgressRingView(
            progress: viewModel.progress,
            goal: viewModel.goal,
            intermediate_goal: viewModel.intermediate_goal,
            intermediate_unit: viewModel.intermediate_unit,
            intermediate_value: viewModel.intermediate_value,
            intermediate_progress: $viewModel.intermediate_progress, // Change this line
            updateProgressInFirebase: {
                viewModel.updateIntermediateProgress(viewModel.intermediate_progress) // Change this line
            }
        )
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
