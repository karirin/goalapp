//
//  GoalViewModel.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Firebase

class GoalViewModel: ObservableObject {
    private var db = Database.database().reference()
    @Published var goal = ""
    @Published var progress = 0.0
    @Published var intermediate_goal = ""
    @Published var intermediate_unit = ""
    @Published var intermediate_value = 0
    @Published var intermediate_progress = 0
    @Published var achievementDates = [Date]()
    @Published var eventDates = [Date]()
    @Published var refresh = false  // Add this line
    @Published var postKey: String?
    @Published var intermediateValues = [Int]()
    @Published var intermediateProgresses = [Int]()
    // Add this to the GoalViewModel
    @Published var intermediateGoals: [IntermediateGoal] = []

    struct IntermediateGoal: Identifiable {
        let id = UUID()
        var goal: String
        var progress: Int
        var unit: String
        var value: Int
    }
    
    func calculateProgressRate() {
        // Check that intermediateGoals is not empty to avoid division by zero
        guard !intermediateGoals.isEmpty else { return }

        // Calculate total progress
        var totalProgressRate = 0.0
        for intermediateGoal in intermediateGoals {
            totalProgressRate += Double(intermediateGoal.progress) / Double(intermediateGoal.value)
            print("totalProgressRate:\(totalProgressRate)")
            print("totalProgressRate:\(Double(intermediateGoal.progress))")
            print("totalProgressRate:\(Double(intermediateGoal.value))")
        }

        // Calculate the average progress rate
        let progress_rate = totalProgressRate / Double(intermediateGoals.count) * 100
        
        print("progress_rate:\(progress_rate)")

        DispatchQueue.main.async {
            // Update the progress state
            self.progress = progress_rate / 100
        }

        // Update the progress_rate in Firebase
        guard let postKey = self.postKey else { return }

        let progressRatePath = "posts/\(postKey)/progress_rate"  // Adjust this path if necessary
        db.child(progressRatePath).setValue(progress_rate) { error, _ in
            if let error = error {
                print("Error updating progress_rate: \(error)")
            } else {
                print("progress_rate updated successfully")
            }
        }
    }


    
    func updateIntermediateProgress(_ progress: Int) {
        guard let postKey = self.postKey else { return }
        
        let progressPath = "posts/\(postKey)/intermediate_goal/0/progress"  // Adjust this path if necessary
        db.child(progressPath).setValue(progress) { error, _ in
            if let error = error {
                print("Error updating data: \(error)")
            } else {
                print("Data updated successfully")
            }
        }

        // Call calculateProgressRate() after updating intermediate_progress
        calculateProgressRate()
    }

    
    func fetchGoal() {
        db.child("posts").getData { [weak self] error, snapshot in
            guard let self = self else { return }
            if let error = error {
                print("Error getting data \(error)")
            } else if let snapshot = snapshot, snapshot.exists(), let postDict = snapshot.value as? [String: [String: Any]] {
                for (key, postData) in postDict {
                    self.postKey = key

                    if let goalValue = postData["goal"] as? String {
                        DispatchQueue.main.async {
                            self.goal = goalValue
                        }
                    }

                    // Clear the intermediateGoals array
                    self.intermediateGoals = []

                    if let intermediate_goals = postData["intermediate_goal"] as? [[String: AnyObject]] {
                        for intermediate_goal in intermediate_goals {
                            if let goal = intermediate_goal["goal"] as? String,
                               let unit = intermediate_goal["unit"] as? String,
                               let value = intermediate_goal["value"] as? Int,
                               let progress = intermediate_goal["progress"] as? Int {
                                DispatchQueue.main.async {
                                    self.intermediate_goal = goal
                                    self.intermediate_unit = unit
                                    self.intermediate_value = value
                                    self.intermediate_progress = progress

                                    // 中間目標をIntermediateGoalとして保存
                                    self.intermediateGoals.append(IntermediateGoal(goal: goal, progress: progress, unit: unit, value: value))
                                }
                            }
                        }
                    }

                    // 全体の進捗率を計算
                    self.calculateProgressRate()
                }
            }
        }
    }

}
