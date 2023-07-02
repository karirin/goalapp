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
    var updateProgressInFirebase: (Int, Int, Date, Bool) -> Void

    var body: some View {
        VStack{
            HStack{
                Text("")
                Spacer()
                Text("目標")
                    .fontWeight(.bold) // <- Change this line
                Spacer()
                Text("")
            }
            .padding()
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.2))
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.8))
            VStack {
                //.frame(height: 40)
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.3)
                        .padding(-20)
                        .padding(.leading,5)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .padding(-20)
                        .padding(.leading,5)
                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
                    
                    VStack {
                        Text(goal)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                    }
                }
                
                ScrollView { // Add this
                    VStack {
                        ForEach(0..<intermediate_goals.count, id: \.self) { index in
                            let intermediate_goal = intermediate_goals[index]
                            HStack{
                                Text(intermediate_goal.goal)
                                    .font(.system(size: 24))
                                    .padding(.top)
                                    .padding(.bottom,1)
                                Spacer()
                            }
                            .padding(.leading)
                            HStack{
                                Button(action: {
                                    let currentDate = Date()  // Get current date
                                    guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { return }
                                    //print("Next day: \(nextDay)")
                                    updateProgressInFirebase(index, intermediate_goal.progress - 1, currentDate, false) // Remove isProgressIncreased label
                                }) {
                                    Image(systemName: "minus.circle")
                                }
                                .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.5))
                                .padding(.leading)
                                .font(.system(size: 30))
                                
                                Spacer()
                                VStack {
                                    HStack {
                                        Text("\(intermediate_goal.progress)")
                                        Text(" / ")
                                        Text("\(intermediate_goal.value)")
                                        Text(intermediate_goal.unit)
                                    }
                                }
                                .font(.system(size: 25))
                                //.padding(.bottom)
                                Spacer()
                                Button(action: {
                                    let currentDate = Date()  // Get current date
                                    //print("currentDate:\(currentDate)")
                                    //guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { return }
                                    //print("Next day: \(nextDay)")
                                    updateProgressInFirebase(index, intermediate_goal.progress + 1, currentDate, true) // Remove isProgressIncreased label
                                }) {
                                    Image(systemName: "plus.circle")
                                }
                                .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.5))
                                .padding(.trailing)
                                .font(.system(size: 30))
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .padding(.top,20)
            .background(Color(red: 0.99, green: 0.99, blue: 0.99, opacity: 1.0))
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
                    updateProgressInFirebase: { index, newProgress, date, isProgressIncreased in
                        viewModel.updateIntermediateProgress(index, newProgress, date, isProgressIncreased: isProgressIncreased)
                    }
                )
            } else {
                // Display a loading indicator or placeholder here
                Text("Loading...")
            }
        }
            .onAppear {
                viewModel.fetchGoal(){
                    
                }
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
