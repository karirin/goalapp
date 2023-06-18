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
    @Published var rewards: [Reward] = []
    @Published var dataFetched = false

    struct IntermediateGoal: Identifiable {
        let id = UUID()
        var goal: String
        var progress: Int
        var unit: String
        var value: Int
    }
    
    struct Reward: Identifiable {
        let id = UUID()
        var name: String
        var progress: Int
    }

    func calculateProgressRate() {
        
        // Check that intermediateGoals is not empty to avoid division by zero
        guard !intermediateGoals.isEmpty else { return }

        // Calculate total progress
        var totalProgressRate = 0.0
        for intermediateGoal in intermediateGoals {
            totalProgressRate += Double(intermediateGoal.progress) / Double(intermediateGoal.value)
        }

        // Calculate the average progress rate
        let progress_rate = totalProgressRate / Double(intermediateGoals.count) * 100

        DispatchQueue.main.async {
            // Update the progress state
            self.progress = progress_rate / 100
        }

        // Update the progress_rate in Firebase
        // Ensure postKey is unwrapped properly
        guard let unwrappedPostKey = self.postKey else { return }
        let progressRatePath = "posts/\(unwrappedPostKey)/progress_rate"
        db.child(progressRatePath).setValue(progress_rate) { error, _ in
            if let error = error {
                print("Error updating progress_rate: \(error)")
            } else {
                print("progress_rate updated successfully")
            }
        }
    }

    func updateIntermediateProgress(_ index: Int, _ progress: Int, _ date: Date) {
        guard index < intermediateGoals.count else { return }
        intermediateGoals[index].progress = progress
        if let unwrappedPostKey = self.postKey {
            let progressPath = "posts/\(unwrappedPostKey)/intermediate_goal/\(index)/progress"
            db.child(progressPath).setValue(progress) { error, _ in
            if let error = error {
                print("Error updating data: \(error)")
            } else {
                print("Data updated successfully")
            }
        }
        // Save click_date to Firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let clickDateString = dateFormatter.string(from: date)
        let datePath = "posts/\(unwrappedPostKey)/intermediate_goal/\(index)/click_date"
        db.child(datePath).setValue(clickDateString)
        // Call calculateProgressRate() after updating intermediate_progress
        calculateProgressRate()
    }
    }
    
    func fetchGoal() {
        db.child("posts").getData { [weak self] error, snapshot in
            guard let self = self else { return }
            if let error = error {
                print("Error getting data \(error)")
            } else if let snapshot = snapshot, snapshot.exists(), let postDict = snapshot.value as? [String: [String: Any]] {
                for (key, postData) in postDict {
                    self.postKey = key

                    if let validKey = key as? String {
                        self.postKey = validKey
                    }

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
                                    self.intermediateGoals.append(IntermediateGoal(goal: goal, progress: progress, unit: unit, value: value))
                                }
                            }
                            // Fetch click_date from Firebase
                            if let clickDateString = intermediate_goal["click_date"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                let clickDate = dateFormatter.date(from: clickDateString)
                                // Here, use the clickDate as needed.
                            }
                        }
                    }

                    self.rewards = []

                    if let rewards = postData["rewards"] as? [[String: AnyObject]] {
                        for reward in rewards {
                            if let name = reward["name"] as? String,
                               let progress = reward["progress"] as? Int {
                                DispatchQueue.main.async {
                                    self.rewards.append(Reward(name: name, progress: progress))
                                }
                            }
                        }
                    }
                    
                    if let achievementDateString = postData["achievement_date"] as? String {
                        // Convert String to Date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo") // Set timeZone to JST
                        if let achievementDate = dateFormatter.date(from: achievementDateString) {
                            DispatchQueue.main.async {
                                self.achievementDates.append(achievementDate)
                            }
                        }
                        print("achievementDateString:\(achievementDateString)")
                    }

                    DispatchQueue.main.async {
                        // 全体の進捗率を計算
                        self.calculateProgressRate()
                        
                        // Set dataFetched to true after fetching data and calculating progress
                        self.dataFetched = true
                    }
                    
                    DispatchQueue.main.async {
                        // Set refresh to true after fetching data
                        self.refresh = true
                    }
                }
            }
        }
    }
}
