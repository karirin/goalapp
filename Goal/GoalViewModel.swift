//
//  GoalViewModel.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Firebase

class GoalViewModel: ObservableObject {
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
    
    private var db = Database.database().reference()
    
    func calculateProgressRate() {
        // Check that intermediate_value is not zero to avoid division by zero
        guard intermediate_value != 0 else { return }

        // Calculate the progress rate
        let progress_rate = Double(intermediate_progress) / Double(intermediate_value) * 100

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
        db.child("posts").getData { error, snapshot in
            if let error = error {
                print("Error getting data \(error)")
            } else if let snapshot = snapshot, snapshot.exists() {
                if let snapshotValue = snapshot.value as? [String: Any] {
                    for (key, value) in snapshotValue {
                        self.postKey = key
                        if let valueDict = value as? [String: Any] {
                            if let goalValue = valueDict["goal"] as? String {
                                DispatchQueue.main.async {
                                    self.goal = goalValue
                                }
                            }
                            if let intermediate_goals = valueDict["intermediate_goal"] as? [[String: AnyObject]] {
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
                                        }
                                    }
                                }
                            }
                            if let progressValue = valueDict["progress_rate"] as? Double {
                                DispatchQueue.main.async {
                                    self.progress = progressValue / 100  // ここでは進捗率を0.0から1.0の範囲に変換します
                                }
                            }
                            if let achievementDateString = valueDict["achievement_date"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Adjust this format to match `achievement_date`
                                if let achievementDate = dateFormatter.date(from: achievementDateString) {
                                    DispatchQueue.main.async {
                                        self.eventDates.append(achievementDate) // Add date to eventDates
                                        print("Event date added: \(achievementDate)")
                                        self.refresh.toggle()  // Toggle refresh after the value is added
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
