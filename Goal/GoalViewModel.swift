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
    
    
    private var db = Database.database().reference()
    
    func fetchGoal() {
        db.child("posts").getData { error, snapshot in
            if let error = error {
                print("Error getting data \(error)")
            } else if let snapshot = snapshot, snapshot.exists() {
                if let snapshotValue = snapshot.value as? [String: Any] {
                    for (key, value) in snapshotValue {
                        if let valueDict = value as? [String: Any] {
                            print(valueDict)
                            if let goalValue = valueDict["goal"] as? String {
                                DispatchQueue.main.async {
                                    self.goal = goalValue
                                }
                            }
                            if let intermediate_goals = valueDict["intermediate_goal"] as? [[String: AnyObject]] {
                                for intermediate_goal in intermediate_goals {
                                    if let goal = intermediate_goal["goal"] as? String,
                                       let unit = intermediate_goal["unit"] as? String,
                                       let value = intermediate_goal["value"] as? Int {
                                        DispatchQueue.main.async {
                                            self.intermediate_goal = goal
                                            self.intermediate_unit = unit
                                            self.intermediate_value = value
                                        }
                                    }
                                }
                            }
                            if let progressValue = valueDict["progress_rate"] as? Double {
                                DispatchQueue.main.async {
                                    self.progress = progressValue / 100  // ここでは進捗率を0.0から1.0の範囲に変換します
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


