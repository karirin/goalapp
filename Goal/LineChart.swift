//
//  LineChart.swift
//
//
//  Created by hashimo ryoya on 2023/06/08.
//

import SwiftUI
import Charts

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
 
    func makeUIView(context: Context) -> LineChartView {
            let lineChartView = LineChartView()
            lineChartView.data = setData()
            
            // lineChartView.backgroundColor = .lightGray //バックグラウンドカラーの変更
            lineChartView.data!.setValueTextColor(.white)
            lineChartView.data!.setDrawValues(true) //データの値表示（falseに設定すると非表示）
            lineChartView.rightAxis.enabled = false //右側のX軸非表示
            lineChartView.animate(xAxisDuration: 2.5) //表示の際のアニメーション効果（この場合はX軸方法で2.5秒）
        lineChartView.data!.setValueFont(.systemFont(ofSize: 20, weight: .light)) //データのフォントサイズとウエイトの変更

            //Y軸表示の設定
            let yAxis = lineChartView.leftAxis // lineChartView.leftAxisを変数で定義
            yAxis.labelFont = .boldSystemFont(ofSize: 12) //Y軸単位のフォントサイズ
            yAxis.setLabelCount(10, force: true) //Y軸の表示罫線数（falseにすると指定無し）
            yAxis.labelTextColor = .white //Y軸単位のテキストカラー
            yAxis.axisLineColor = .white //Y軸単位の軸のカラー
            yAxis.labelPosition = .outsideChart //Y軸単位のポジション(.insideChartにすると内側で表示)
            
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
        guard let baseDate = dateFormatter.date(from: "06/01") else {
            return lineChartView
        }
        
        //ValueFormatterを作成し、数値を日付に変換します
        xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (value, axis) in
            let date = Date(timeIntervalSinceReferenceDate: value * 60 * 60 * 24 + baseDate.timeIntervalSinceReferenceDate)
            return dateFormatter.string(from: date)
        })
        
        return lineChartView
        }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = setData()
    }
    
    func setData() -> LineChartData {
        var dataSets: [LineChartDataSet] = []
        let colors: [NSUIColor] = [.red, .blue, .green, .orange, .purple, .cyan] // 線ごとの色設定

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        //基準日（グラフの最初の日）を設定します
        guard let baseDate = dateFormatter.date(from: "2023-06-01") else {
            return LineChartData() // 基準日の設定が失敗した場合は空のデータを返します
        }

        for (index, intermediateGoal) in viewModel.intermediateGoals.enumerated() {
            var dataPoints: [ChartDataEntry] = []
            
            // intermediateGoal.clicksを日付順にソートします
            let sortedClicks = intermediateGoal.clicks.sorted(by: { $0.clickDate < $1.clickDate })
            
            for click in sortedClicks {
                let date = dateFormatter.string(from: click.clickDate)
                let value = Double(click.clickCount)

                //基準日からの経過日数を算出します
                let elapsedTime = click.clickDate.timeIntervalSince(baseDate) / (60 * 60 * 24)
                
                dataPoints.append(ChartDataEntry(x: elapsedTime, y: value))
            }
            
            let set = LineChartDataSet(entries: dataPoints, label: " \(intermediateGoal.goal)")
            set.valueFont = .systemFont(ofSize: 20)
            //set.mode = .cubicBezier // 線表示を曲線で表示
            set.drawCirclesEnabled = false // 各データを丸記号表示を非表示
            set.lineWidth = 1.5 // 線の太さの指定
            set.setColor(colors[index % colors.count]) // 線の色の指定
            set.fillAlpha = 0.5 // 塗りつぶし色の不透明度指定
            set.drawFilledEnabled = false // 値の塗りつぶし表示
            dataSets.append(set)
        }

        return LineChartData(dataSets: dataSets)
    }
    
    func getChartData() -> [ChartDataEntry] {
        var chartData: [ChartDataEntry] = []
        for (index, intermediateGoal) in viewModel.intermediateGoals.enumerated() {
            print("intermediateGoal:\(intermediateGoal.clicks)")
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

    var body: some View {
        LineChart(viewModel: viewModel)
            .onAppear {
                viewModel.fetchGoal()
            }
    }
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .frame(height:300)
    }
}
