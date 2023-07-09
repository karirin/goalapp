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
    @Published var selectedYear = ""
    @Published var selectedMonth = ""
//var cancellables = Set<AnyCancellable>()
    @Published var showRewardAchievedAlert = false
    @Published var selectedDateType: DateType = .none  // Add this line
    @Published var showRootView: Bool = false

    init() {
        let date = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        selectedYear = String(components.year ?? 2023)  // 現在の年
        selectedMonth = String(format: "%02d", components.month ?? 1)  // 現在の月（1桁の場合は0でパディング）
    }
    
    struct Reward: Identifiable {
        let id = UUID()
        var name: String
        var progress: Int
    }

    struct Click: Equatable, Hashable {
        let id = UUID()
        var clickCount: Int
        var clickDate: Date
    }

    struct IntermediateGoal: Identifiable, Hashable {
        let id = UUID()
        var goal: String
        var progress: Int
        var unit: String
        var value: Int
        var clicks: [Click] // `Click` is now `Hashable`
        let date: Date  // 追加
        var isAchievementDate: Bool  // 新しいフラグ
        var isIntermediateGoalDate: Bool  // 新しいフラグ
    }
    
    struct ClickInfo {
        var date: Date
        var count: Int
    }
    
    enum FirebaseError: Error {
        case userNotLoggedIn
        case noDataAvailable
    }
    
    enum DateType {
        case none
        case goalAchievement
        case intermediateGoal
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

    func fetchGoal(completion: @escaping () -> Void) {
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
                    print("postKey fetched: \(self.postKey ?? "nil")")  // Log the fetched postKey

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
                               let progress = intermediate_goal["progress"] as? Int,
                               let dateString = intermediate_goal["date"] as? String {  // 追加
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
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                guard let date = dateFormatter.date(from: dateString) else {
                                    print("Invalid date string: \(dateString)")
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.intermediateGoals.append(IntermediateGoal(goal: goal, progress: progress, unit: unit, value: value, clicks: clicks, date: date, isAchievementDate: false, isIntermediateGoalDate: false))
                                }
                            }
                        }
                    } else {
                        print("Failed to parse intermediate_goal: \(postData["intermediate_goal"] ?? "nil")")
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
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    func calculateRewardProgressRate() -> Double {
        // Step 1: Calculate the total progress of all intermediate goals
        var totalProgress = 0.0
        for intermediateGoal in intermediateGoals {
            totalProgress += Double(intermediateGoal.progress) / Double(intermediateGoal.value)
            print("totalProgress:\(totalProgress)")
        }

        // Step 2: Calculate the total target progress of all rewards
        var totalTargetProgress = 0.0
        for reward in rewards {
            totalTargetProgress += Double(reward.progress)
            print("totalTargetProgress:\(totalTargetProgress)")
        }

        // If totalTargetProgress is 0, return 0.0 to avoid division by 0
        if totalTargetProgress == 0.0 {
            return 0.0
        }

        // Calculate the reward progress rate
        let rewardProgressRate = totalProgress / totalTargetProgress * 100
        print("rewardProgressRate:\(rewardProgressRate)")
        
        if rewardProgressRate >= 100.0 {
            DispatchQueue.main.async {
                self.showRewardAchievedAlert = true
            }
        }

        // Return the reward progress rate
        return rewardProgressRate
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
    
    func deleteGoal(completion: @escaping (Result<Void, Error>) -> Void) {
            guard let postKey = self.postKey else {
                completion(.failure(FirebaseError.noDataAvailable))
                print("postKey:\(postKey)")
                return
            }

            if let validPostKey = postKey as? String {
            // `validPostKey`が`nil`でないことが保証されているブロック内で、Firebaseの操作を行います
            db.child("posts/\(validPostKey)").removeValue { error, _ in
                if let error = error {
                    print("Error removing goal: \(error)")
                    completion(.failure(error))
                } else {
                    print("Goal removed successfully")
                    completion(.success(()))
                }
            }
        } else {
            // `postKey`が`nil`の場合のエラーハンドリングを行います
            completion(.failure(FirebaseError.noDataAvailable))
        }
    }

    func deleteGoalWithConfirmation(onConfirmed: @escaping () -> Void) {
        let alertController = UIAlertController(title: "目標を削除", message: "本当に今の目標を削除してもいいですか？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "削除", style: .destructive) { _ in
            self.deleteGoal { result in
                switch result {
                case .success():
                    print("Goal deleted")
                    onConfirmed()
                    DispatchQueue.main.async {
                        self.showRootView = true
                    }
                case .failure(let error):
                    print("Failed to delete goal: \(error)")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(alertController, animated: true)
        }
    }
}

// `Reward`の`extension`を`GoalViewModel`の外部に移動
extension GoalViewModel.Reward {
    func progressRate(for intermediateGoals: [GoalViewModel.IntermediateGoal]) -> Int {
        var totalProgress = 0.0
        
        for intermediateGoal in intermediateGoals {
            totalProgress += Double(intermediateGoal.progress) / Double(intermediateGoal.value)
        }

        let progress_rate = totalProgress / Double(intermediateGoals.count) * 100
        
        // Calculate the reward's progress rate and convert it to an Int
        let rewardProgressRate = Int(progress_rate / Double(self.progress) * 100)

        print("rewardProgressRate:\(rewardProgressRate)")
        
        return rewardProgressRate
    }
}
