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
    @Binding var selectedDate: Date  // Bindingを追加
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
        //ヘッダー
        fsCalendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20) //ヘッダーテキストサイズ
        fsCalendar.appearance.headerDateFormat = "yyyy/MM" //ヘッダー表示のフォーマット
        fsCalendar.appearance.headerTitleColor = UIColor.label //ヘッダーテキストカラー
        fsCalendar.appearance.headerMinimumDissolvedAlpha = 0 //前月、翌月表示のアルファ量（0で非表示）
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
        
        fsCalendar.appearance.borderRadius = 0 //本日・選択日の塗りつぶし角丸量
        
        return fsCalendar
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if refresh {
            uiView.setNeedsLayout()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel) // Pass ViewModel to the Coordinator
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarUIView
        var viewModel: GoalViewModel
        let dateFormatter = DateFormatter()
        
        init(_ parent: CalendarUIView, viewModel: GoalViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let eventDates = viewModel.eventDates.map { dateFormatter.string(from: $0) }  // viewModelから最新のeventDatesを取得
            print(eventDates)
            let dateString = dateFormatter.string(from: date)
            //print(dateString)
            if eventDates.contains(dateString) {
                return 1
            }
            return 0
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date  // selectedDateを直接更新
        }
    }
}

struct CalendarTestView: View {
    @State var selectedDate = Date()
    @StateObject var viewModel = GoalViewModel()
    
    var body: some View {
        VStack{
            CalendarUIView(selectedDate: $selectedDate, viewModel: viewModel, refresh: $viewModel.refresh) // Pass refresh binding to the CalendarUIView
                .frame(height: 400)
            Text(selectedDate,style: .date)
                .font(.title)
                .padding()
        }.onAppear {
            viewModel.fetchGoal() // Fetch data when view appears
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTestView()
    }
}
