//
//  LineChart.swift
//
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Charts

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class DateValueFormatter: AxisValueFormatter {
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "M/d" // 月/日 の形式で表示します。
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value) // `value` をエポック時間として解釈
        return dateFormatter.string(from: date)
    }
}

struct LineChart : UIViewRepresentable {
    @ObservedObject var viewModel: GoalViewModel
    typealias UIViewType = LineChartView
    @State private var maxYValue: Double = 0.0
 
    func makeUIView(context: Context) -> LineChartView {
        let lineChartView = LineChartView()
        
        let (data, maxYValue) = setData()
        lineChartView.data = data
            
            // lineChartView.backgroundColor = .lightGray //バックグラウンドカラーの変更
            lineChartView.data!.setValueTextColor(.white)
            lineChartView.data!.setDrawValues(true) //データの値表示（falseに設定すると非表示）
            lineChartView.rightAxis.enabled = false //右側のX軸非表示
            lineChartView.animate(xAxisDuration: 2.5) //表示の際のアニメーション効果（この場合はX軸方法で2.5秒）
            lineChartView.data!.setValueFont(.systemFont(ofSize: 20, weight: .light)) //データのフォントサイズとウエイトの変更

        let yAxis = lineChartView.leftAxis
        yAxis.drawLabelsEnabled = true  // これによりY軸のラベルが表示されます
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(10, force: true)
        //yAxis.labelTextColor = .white
        //yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        yAxis.axisMinimum = 0.0  // y軸の最小値
        //yAxis.axisMaximum = 100.0  // y軸の最大値
        yAxis.axisMaximum = maxYValue

        // X軸表示の設定
        let xAxis = lineChartView.xAxis // lineChartView.xAxisを変数で定義
        xAxis.labelPosition = .bottom //X軸の表示位置をBottomに設定
        xAxis.labelFont = .systemFont(ofSize: 10) //X軸のフォントサイズを10に設定
        xAxis.labelTextColor = .black //X軸のテキストカラーを黒に設定
        //xAxis.labelRotationAngle = −90 // X軸のラベルを90度回転
        
        //日付のフォーマットを設定します
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"

        //基準日を設定します
        guard let baseDate = dateFormatter.date(from: "\(viewModel.selectedMonth)/01") else {
            return lineChartView
        }

        //終了日を設定します
        guard let endDate = dateFormatter.date(from: "\(viewModel.selectedMonth)/30") else {
            return lineChartView
        }

        //基準日からの最小値と最大値を算出します
        let minimumValue = 0.0
        let maximumValue = endDate.timeIntervalSince(baseDate) / (60 * 60 * 24)

        //X軸の最小値と最大値を設定します
        xAxis.axisMinimum = minimumValue
        xAxis.axisMaximum = maximumValue

        //ValueFormatterを作成し、数値を日付に変換します
        xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (value, axis) in
            let date = Date(timeIntervalSinceReferenceDate: value * 60 * 60 * 24 + baseDate.timeIntervalSinceReferenceDate)
            return dateFormatter.string(from: date)
        })
        
        return lineChartView
        }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        let (data, newMaxYValue) = setData()
        uiView.data = data

        // Y軸の最大値も更新します
        uiView.leftAxis.axisMaximum = newMaxYValue
    }
    
    func setData() -> (LineChartData, Double) {
        var dataSets: [LineChartDataSet] = []
        let colors: [NSUIColor] = [.red, .blue, .green, .orange, .purple, .cyan] // 線ごとの色設定
        //var maxValue: Double = 0.0 // 最大値を格納する変数を追加
        var maxValue: Double = -Double.infinity // 最大値を格納する変数を追加
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // 基準日（グラフの最初の日）を設定します
        guard let baseDate = dateFormatter.date(from: "\(viewModel.selectedYear)-\(viewModel.selectedMonth)-01") else {
            return (LineChartData(), 0.0) // 基準日の設定が失敗した場合は空のデータと0の最大値を返します
        }

        // 終了日を設定します
        guard let endDate = dateFormatter.date(from: "\(viewModel.selectedYear)-\(viewModel.selectedMonth)-30") else {
            return (LineChartData(), 0.0) // 終了日の設定が失敗した場合は空のデータと0の最大値を返します
        }

        for (index, intermediateGoal) in viewModel.intermediateGoals.enumerated() {
            var dataPoints: [ChartDataEntry] = []

            // 選択された月を表す DateComponents を作成
            let selectedYear = 2023 // ここには適切な年を設定してください
            let selectedMonth = Int(viewModel.selectedMonth) ?? 1
            var selectedMonthComponents = DateComponents()
            selectedMonthComponents.year = selectedYear
            selectedMonthComponents.month = selectedMonth

            // intermediateGoal.clicksを日付順にソートします
            let sortedClicks = intermediateGoal.clicks.sorted(by: { $0.clickDate < $1.clickDate })

            for click in sortedClicks {
                // このclickの日付が選択された月と同じであるかを確認します
                let clickDateComponents = Calendar.current.dateComponents([.year, .month], from: click.clickDate)
                if clickDateComponents.year == selectedMonthComponents.year && clickDateComponents.month == selectedMonthComponents.month {
                    let value = Double(click.clickCount)
                    print("value: \(value)")
                    // 最大値を更新
                    if value > maxValue {
                        maxValue = value
                        print("maxValue updated: \(maxValue)")
                    }

                    //基準日からの経過日数を算出します
                    let elapsedTime = click.clickDate.timeIntervalSince(baseDate) / (60 * 60 * 24)

                    dataPoints.append(ChartDataEntry(x: elapsedTime, y: value))
                }
            }
            
            let set = LineChartDataSet(entries: dataPoints, label: " \(intermediateGoal.goal)")
            set.valueFont = .systemFont(ofSize: 20)
            set.drawCirclesEnabled = false // 各データを丸記号表示を非表示
            set.lineWidth = 1.5 // 線の太さの指定
            set.setColor(colors[index % colors.count]) // 線の色の指定
            set.fillAlpha = 0.5 // 塗りつぶし色の不透明度指定
            set.drawFilledEnabled = false // 値の塗りつぶし表示
            set.drawValuesEnabled = false
            set.circleRadius = 5.0 // 丸の半径を5.0に設定
            set.circleColors = [.black] // 丸の色を青に設定
            dataSets.append(set)
        }

        let lineChartData = LineChartData(dataSets: dataSets)

        return (LineChartData(dataSets: dataSets), maxValue)
    }

    func getChartData() -> [ChartDataEntry] {
        var chartData: [ChartDataEntry] = []
        for (index, intermediateGoal) in viewModel.intermediateGoals.enumerated() {
            for click in intermediateGoal.clicks {
                let date = click.clickDate.timeIntervalSince1970 // 日付をエポック時間に変換
                let value = Double(click.clickCount)
                chartData.append(ChartDataEntry(x: date, y: value)) // `x` をエポック時間にします。
            }
        }
        // chartDataをx値（エポック時間）でソート
        chartData.sort(by: { $0.x < $1.x })
        return chartData
    }

    
    func getDataPoints(accuracy: [ChartDataEntry]) -> [ChartDataEntry] {
        var dataPoints: [ChartDataEntry] = []
        
        for count in (0..<accuracy.count) {
            dataPoints.append(ChartDataEntry(x: Double(count), y: accuracy[count].y))
        }
        return dataPoints
    }
}

struct ChartView: View {
    @ObservedObject var viewModel = GoalViewModel()

    var years: [String] = Array(2000...2030).map { String($0) }
    var months: [String] = (1...12).map { String(format: "%02d", $0) }


    var body: some View {
        let groupedGoals = viewModel.intermediateGoals.chunked(into: 2)
        VStack{
            HStack{
                Text("")
                Spacer()
                Image(systemName: "chevron.left")
                    .onTapGesture {
                        // 「<」をクリックしたときのアクション
                        // 選択した月を一つ減らす
                        var newMonth = (Int(viewModel.selectedMonth) ?? 1) - 1
                        if newMonth < 1 {
                            newMonth = 12
                            viewModel.selectedYear = String(Int(viewModel.selectedYear)! - 1)
                        }
                        viewModel.selectedMonth = String(format: "%02d", newMonth)
                    }
                Text("\(viewModel.selectedYear)年\(viewModel.selectedMonth)月")
                    .onReceive(viewModel.$selectedYear) { _ in // selectedYearが変わるたびに呼ばれる
                        viewModel.fetchGoal(){
                            
                        }
                    }
                    .padding(.horizontal)
                Image(systemName: "chevron.right")
                    .onTapGesture {
                        // 「>」をクリックしたときのアクション
                        // 選択した月を一つ増やす
                        var newMonth = (Int(viewModel.selectedMonth) ?? 1) + 1
                        if newMonth > 12 {
                            newMonth = 1
                            viewModel.selectedYear = String(Int(viewModel.selectedYear)! + 1)
                        }
                        viewModel.selectedMonth = String(format: "%02d", newMonth)
                    }
                Spacer()
                Text("")
            }
            .padding()
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            .foregroundColor(.white)
            .frame(height:50)
            .fontWeight(.bold)
            .font(.system(size: 20))
            VStack {
                // 必要に応じて条件を設けてチャートを描画する
                if !viewModel.intermediateGoals.isEmpty {
                    HStack{
                        Image(systemName: "chart.line.uptrend.xyaxis.circle")
                            .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
                        Text("中間目標の進捗推移")
                        Spacer()
                    }
                    .font(.system(size: 25))
                    .padding(.bottom,-1)
                    .padding(.horizontal,5)
                    LineChart(viewModel: viewModel)
                        .frame(maxWidth:.infinity, maxHeight: 200)
                }
                HStack{
                    Image(systemName: "chart.pie")
                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
                    Text("中間目標の進捗率")
                    Spacer()
                }
                .font(.system(size: 25))
                .padding(.bottom,-1)
                .padding(.horizontal,5)
                .padding(.top)
                ScrollView{
                    VStack {
                        ForEach(groupedGoals, id: \.self) { goalPair in
                            HStack {
                                ForEach(goalPair) { goal in
                                    VStack {
                                        Text(goal.goal)
                                        CircularProgressView(progress: Double(goal.progress), total: Double(goal.value))
                                            .frame(width: 100, height: 100)
                                    }
                                    .padding()
                                    .padding(.horizontal,5)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(.top,30)
            .padding(.horizontal,5)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 20 { // 右方向にスワイプ
                        viewModel.selectedMonth = String(format: "%02d", (Int(viewModel.selectedMonth) ?? 1) - 1)
                    } else if value.translation.width < -20 { // 左方向にスワイプ
                        viewModel.selectedMonth = String(format: "%02d", (Int(viewModel.selectedMonth) ?? 1) + 1)
                    }
                }
        )
    }
}



struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            //.frame(height:300)
        
    }
}
