//
//  GoalViewModel.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Firebase
import Combine

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
    @Published var intermediateGoals: [IntermediateGoal] = []
    @Published var rewards: [Reward] = []
    @Published var dataFetched = false
    @Published var selectedMonth: String = "06"
//var cancellables = Set<AnyCancellable>()

    struct Click: Identifiable {
        let id = UUID()
        var clickCount: Int
        var clickDate: Date
    }

    struct IntermediateGoal: Identifiable {
        let id = UUID()
        var goal: String
        var progress: Int
        var unit: String
        var value: Int
        var clicks: [Click] // Add this line
    }
    
    struct Reward: Identifiable {
        let id = UUID()
        var name: String
        var progress: Int
    }
    
    struct ClickInfo {
        var date: Date
        var count: Int
    }
    
    enum FirebaseError: Error {
        case userNotLoggedIn
        case noDataAvailable
    }

    
    func calculateProgressRate() {
        
        guard !intermediateGoals.isEmpty else { return }

        var totalProgressRate = 0.0
        for intermediateGoal in intermediateGoals {
            totalProgressRate += Double(intermediateGoal.progress) / Double(intermediateGoal.value)
        }

        let progress_rate = totalProgressRate / Double(intermediateGoals.count) * 100

        DispatchQueue.main.async {
            self.progress = progress_rate / 100
        }

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

    func updateIntermediateProgress(_ index: Int, _ newProgress: Int, _ date: Date, isProgressIncreased: Bool = true) { // Add isProgressIncreased parameter
        guard index < intermediateGoals.count else { return }

        let oldProgress = intermediateGoals[index].progress

        intermediateGoals[index].progress = newProgress

        if let unwrappedPostKey = self.postKey {
            let progressPath = "posts/\(unwrappedPostKey)/intermediate_goal/\(index)/progress"
            db.child(progressPath).setValue(newProgress) // Error handling omitted for brevity

            let clickCountPath = "posts/\(unwrappedPostKey)/intermediate_goal/\(index)/clicks"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let clickDateString = dateFormatter.string(from: date)

            db.child(clickCountPath).queryOrdered(byChild: "click_date").queryEqual(toValue: clickDateString).getData { [weak self] (error, snapshot) in
                guard let self = self else { return }

                if let error = error {
                    print("Error getting data \(error)")
                } else if let snapshot = snapshot, snapshot.exists(), let value = snapshot.value as? [String: Any], let key = value.keys.first {
                    if var clickData = value[key] as? [String: Any], let clickCount = clickData["click_count"] as? Int {
                        // When progress increased, increase the click count
                        if isProgressIncreased {
                            clickData["click_count"] = clickCount + 1
                            db.child("\(clickCountPath)/\(key)").setValue(clickData)
                        }
                        // When progress decreased, decrease the click count
                        else {
                            // When click count > 1, decrease the click count
                            if clickCount > 1 {
                                clickData["click_count"] = clickCount - 1
                                db.child("\(clickCountPath)/\(key)").setValue(clickData)
                            }
                            // When click count = 1, remove the click data
                            else {
                                db.child("\(clickCountPath)/\(key)").removeValue()
                            }
                        }
                    }
                } else if isProgressIncreased {
                    let clickData: [String: Any] = [
                        "click_count": 1,
                        "click_date": clickDateString
                    ]
                    db.child(clickCountPath).childByAutoId().setValue(clickData) // Error handling omitted for brevity
                }
            }

            calculateProgressRate()
        }
    }

    func fetchGoal() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        db.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: userID).getData { [weak self] error, snapshot in
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

                    self.intermediateGoals = []

                    if let intermediate_goals = postData["intermediate_goal"] as? [[String: AnyObject]] {
                        for intermediate_goal in intermediate_goals {
                            if let goal = intermediate_goal["goal"] as? String,
                               let unit = intermediate_goal["unit"] as? String,
                               let value = intermediate_goal["value"] as? Int,
                               let progress = intermediate_goal["progress"] as? Int {
                                var clicks: [Click] = [] // Initialize the clicks array

                                if let clicksData = intermediate_goal["clicks"] as? [String: [String: Any]] {
                                    for (_, clickData) in clicksData {
                                        if let clickCount = clickData["click_count"] as? Int,
                                            let clickDateString = clickData["click_date"] as? String {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            if let clickDate = dateFormatter.date(from: clickDateString) {
                                                clicks.append(Click(clickCount: clickCount, clickDate: clickDate))
                                            }
                                        }
                                    }
                                }


                                DispatchQueue.main.async {
                                    self.intermediateGoals.append(IntermediateGoal(goal: goal, progress: progress, unit: unit, value: value, clicks: clicks))
                                }
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
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo") // Set timeZone to JST
                        if let achievementDate = dateFormatter.date(from: achievementDateString) {
                            DispatchQueue.main.async {
                                self.achievementDates.append(achievementDate)
                            }
                        }
                        //print("achievementDateString:\(achievementDateString)")
                    }

                    DispatchQueue.main.async {
                        self.calculateProgressRate()
                        
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
    
    func intermediateGoalsAndClickCounts(on date: Date) -> [(IntermediateGoal, Int)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var results: [(IntermediateGoal, Int)] = []

        for intermediateGoal in intermediateGoals {
            var clickCount = 0
            for click in intermediateGoal.clicks {
                let clickDateString = dateFormatter.string(from: click.clickDate)
               print("clickDateString:\(clickDateString)")
                if clickDateString == dateString {
                    clickCount += click.clickCount
                }
            }
            if clickCount > 0 {
                results.append((intermediateGoal, clickCount))
            }
        }

        return results
    }
    
    func clickCount(on date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var totalClickCount = 0
        
        //print("intermediateGoals:\(intermediateGoals)")

        for intermediateGoal in intermediateGoals {
            for click in intermediateGoal.clicks {
                let clickDateString = dateFormatter.string(from: click.clickDate)
                if clickDateString == dateString {
                    totalClickCount += click.clickCount
                }
            }
        }

        return totalClickCount
    }
}
