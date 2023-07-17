//
//  CalendarView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI
import FSCalendar
import UIKit
 
struct CalendarUIView: UIViewRepresentable {
    @Binding var selectedDate: Date?  // Change to optional
    @ObservedObject var viewModel: GoalViewModel
    @Binding var refresh: Bool  // Add this line
    
    func makeUIView(context: Context) -> UIView {
        typealias UIViewType = FSCalendar
        let fsCalendar = FSCalendar()
        
        fsCalendar.delegate = context.coordinator
        fsCalendar.dataSource = context.coordinator
        //カスタマイズ
        //表示
        fsCalendar.scrollDirection = .vertical //スクロールの方向
        fsCalendar.scope = .month //表示の単位（週単位 or 月単位）
        fsCalendar.locale = Locale(identifier: "en") //表示の言語の設置（日本語表示の場合は"ja"）
        //曜日表示
        fsCalendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 20) //曜日表示のテキストサイズ
        fsCalendar.appearance.weekdayTextColor = .darkGray //曜日表示のテキストカラー
        fsCalendar.appearance.titleWeekendColor = .red //週末（土、日曜の日付表示カラー）
        //カレンダー日付表示
        fsCalendar.appearance.titleFont = UIFont.systemFont(ofSize: 16) //日付のテキストサイズ
        fsCalendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold) //日付のテキスト、ウェイトサイズ
        fsCalendar.appearance.todayColor = .clear //本日の選択カラー
        fsCalendar.appearance.titleTodayColor = .orange //本日のテキストカラー
        
        fsCalendar.appearance.selectionColor = .clear //選択した日付のカラー
        fsCalendar.appearance.borderSelectionColor = .blue //選択した日付のボーダーカラー
        fsCalendar.appearance.titleSelectionColor = .black //選択した日付のテキストカラー
        
        fsCalendar.appearance.borderRadius = 1 //本日・選択日の塗りつぶし角丸量
        
        fsCalendar.appearance.subtitleOffset = CGPoint(x: 0, y: 10)  // Adjust the position of subtitle label
            fsCalendar.appearance.eventOffset = CGPoint(x: 0, y: -10)  // Adjust the position of event dot
        fsCalendar.headerHeight = 0  // ヘッダーの高さを0に設定
        
        return fsCalendar
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let fsCalendar = uiView as? FSCalendar, refresh {
            fsCalendar.reloadData()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel) // Pass ViewModel to the Coordinator
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarUIView
        var viewModel: GoalViewModel
        let dateFormatter = DateFormatter()
        
        init(_ parent: CalendarUIView, viewModel: GoalViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            self.dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        func isToday(_ date: Date) -> Bool {
            let calendar = Calendar.current
            return calendar.isDateInToday(date)
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let goalsAndClicks = viewModel.intermediateGoalsAndClickCounts(on: date)
            //print("date:\(date)")
            //print("goalsAndClicks:\(goalsAndClicks)")
            // クリック数が1以上のイベントだけをカウントします。(
            let eventCount = goalsAndClicks.filter { $1 >= 1 }.count
            //print("eventCount:\(eventCount)")
            return eventCount
        }
        
        // Add this in CalendarUIView's Coordinator class
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                self.parent.selectedDate = date

                let isGoalAchievementDate = self.viewModel.achievementDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
                let isIntermediateGoalDate = self.viewModel.intermediateGoals.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })

                if isGoalAchievementDate {
                    self.viewModel.selectedDateType = .goalAchievement
                } else if isIntermediateGoalDate {
                    self.viewModel.selectedDateType = .intermediateGoal
                } else {
                    self.viewModel.selectedDateType = .none
                }
            }
        }


        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")! // Set timeZone to JST
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let achievementDatesComponents = viewModel.achievementDates.map { calendar.dateComponents([.year, .month, .day], from: $0) }
            let intermediateGoalDatesComponents = viewModel.intermediateGoals.map { calendar.dateComponents([.year, .month, .day], from: $0.date) } // 追加
            if isToday(date) {
                return .black // 今日の文字色を先にチェックして、黒に設定
            } else if achievementDatesComponents.contains(components) || intermediateGoalDatesComponents.contains(components) {
                return .white // 次に達成日と中間目標の達成日の文字色を白に設定
            }
            return nil // 他の日付はデフォルトの色に
        }

        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")! // Set timeZone to JST
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let achievementDatesComponents = viewModel.achievementDates.map { calendar.dateComponents([.year, .month, .day], from: $0) }
            print("achievementDatesComponents:\(achievementDatesComponents)")
            let intermediateGoalDatesComponents = viewModel.intermediateGoals.map { calendar.dateComponents([.year, .month, .day], from: $0.date) }  // 追加
            print("intermediateGoalDatesComponents:\(intermediateGoalDatesComponents)")
            if achievementDatesComponents.contains(components) {
                return .red // 達成日の背景色を赤に
            } else if intermediateGoalDatesComponents.contains(components) {  // 追加
                return .blue // 中間目標の達成日の背景色を青に
            } else if isToday(date) {
                return .white // 今日の背景色を白に
            }
            return nil // 他の日付はデフォルトの色に
        }

        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            let currentPageDate = calendar.currentPage
            let components = Calendar.current.dateComponents([.year, .month], from: currentPageDate)
            viewModel.selectedYear = String(components.year ?? 2023)  // Update selectedYear in viewModel
            viewModel.selectedMonth = String(format: "%02d", components.month ?? 1)  // Update selectedMonth in viewModel
        }

    }
}

struct CalendarTestView: View {
    @State var selectedDate: Date?  // Change to optional
    @StateObject var viewModel = GoalViewModel()
    @State var selectedGoalsAndClicks: [(GoalViewModel.IntermediateGoal, Int)] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
    
    var body: some View {
        VStack{
            HStack{
                HelpView1()
                    .opacity(0)
                Spacer()
                Text("\(viewModel.selectedYear)年\(viewModel.selectedMonth)月")
                    .fontWeight(.bold) // <- Change this line
                Spacer()
                HelpView2()
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            //.foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.8))
            .foregroundColor(.white)
            .frame(height:50)
            .font(.system(size: 20))
            CalendarUIView(selectedDate: $selectedDate, viewModel: viewModel, refresh: $viewModel.refresh) // Pass refresh binding to the CalendarUIView
                .frame(height: 400)
                .padding(.top)
            ScrollView {
                VStack{
                    HStack{
                        Text(selectedDate != nil ? dateFormatter.string(from: selectedDate!) : "日付が選択されていません")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.leading,15)
                    .padding(.bottom,5)
                    if viewModel.selectedDateType == .goalAchievement {
                        VStack{
                            HStack{
                                Text(" ")
                                    .frame(width:5,height: 20)
                                    .background(Color(red: 0.99, green: 0.4, blue: 0.4, opacity: 1.0))
                                Text("目標の達成日です")
                                Spacer()
                            }
                        }
                        .font(.system(size: 20))
                        .padding(.horizontal)
                        .padding(.bottom,5)
                    } else if viewModel.selectedDateType == .intermediateGoal {
                        if let intermediateGoal = viewModel.intermediateGoals.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate!) }) {
                                VStack{
                                    HStack{
                                        Text(" ")
                                            .frame(width:5,height: 20)
                                            .background(Color(red: 0.99, green: 0.4, blue: 0.4, opacity: 1.0))
                                        Text("中間目標")
                                        Spacer()
                                    }
                                    HStack{
                                        Text("\(intermediateGoal.goal)")
                                        Text("の達成日です")
                                        Spacer()
                                    }
                                }
                                .font(.system(size: 20))
                                .padding(.horizontal)
                                .padding(.bottom,5)
                        }
                    }

                    ForEach(selectedGoalsAndClicks, id: \.0.id) { goal, clickCount in
                        HStack{
                            Text(" ")
                                .frame(width:5,height: 20)
                                .background(Color(red: 0.99, green: 0.4, blue: 0.4, opacity: 1.0))
                            Text("\(goal.goal)")
                            Spacer()
                            Text("\(clickCount) \(goal.unit)")
                        }
                        .font(.system(size: 20))
                        .padding(.horizontal)
                        .padding(.bottom,5)
                    }
                    Spacer()
                }.frame(height: 100)
            }
        }.onAppear {
            viewModel.fetchGoal() {
                // Fetch data when view appears
            }
        }
        .onChange(of: selectedDate) { newDate in
            guard let newDate = newDate else {
                // If no date is selected, clear the goals and clicks
                self.selectedGoalsAndClicks = []
                return
            }
            var goalsAndClicks = viewModel.intermediateGoalsAndClickCounts(on: newDate)
            for (index, goalAndClick) in goalsAndClicks.enumerated() {
                var (goal, clickCount) = goalAndClick
                let isAchievementDate = viewModel.achievementDates.contains { Calendar.current.isDate($0, inSameDayAs: newDate) }
                let isIntermediateGoalDate = viewModel.intermediateGoals.map { $0.date }.contains { Calendar.current.isDate($0, inSameDayAs: newDate) }
                print("Achievement date: \(isAchievementDate), Intermediate goal date: \(isIntermediateGoalDate)")
                goal.isAchievementDate = isAchievementDate
                goal.isIntermediateGoalDate = isIntermediateGoalDate
                goalsAndClicks[index] = (goal, clickCount)
            }
            selectedGoalsAndClicks = goalsAndClicks
        }


        .background(Color(red: 0.99, green: 0.99, blue: 0.99, opacity: 1.0))
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTestView()
    }
}
