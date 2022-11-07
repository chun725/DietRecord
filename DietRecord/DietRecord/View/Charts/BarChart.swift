//
//  BarChart.swift
//  DietRecord
//
//  Created by chun on 2022/11/2.
//

import Foundation
import Charts

class BarChart: BarChartView {
    init(frame: CGRect, superview: UIView) {
        super.init(frame: frame)
        initView(superview: superview)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(superview: UIView) {
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        configureConstraint(superview: superview)
    }
    
    private func configureConstraint(superview: UIView) {
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 1),
            self.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    func setBarChart(date: String, foodDailyInputs: [FoodDailyInput]?, goal: Double) {
        guard let date = dateFormatter.date(from: date) else { return }
        let firstDate = date.advanced(by: -60 * 60 * 24 * 6)
        let referenceTimeInterval = firstDate.timeIntervalSince1970
        barChartDateFormatter.dateFormat = "MM/dd"
        barChartDateFormatter.locale = .current
        
        let xValuesNumberFormatter = ChartXAxisFormatter(
            referenceTimeInterval: referenceTimeInterval,
            dateFormatter: barChartDateFormatter)
        self.xAxis.valueFormatter = xValuesNumberFormatter
        
        var dataEntries: [BarChartDataEntry] = []
        guard let foodDailyInputs = foodDailyInputs
        else {
            self.configureBarChart(dataEntries: dataEntries, goal: goal)
            return
        }
        for foodDailyInput in foodDailyInputs {
            let breakfastFoods = foodDailyInput.mealRecord.first { $0.meal == 0 }?.foods
            let breakfastCalories = calculateMacroNutrition(foods: breakfastFoods, nutrient: .calories)
            
            let lunchFoods = foodDailyInput.mealRecord.first { $0.meal == 1 }?.foods
            let lunchCalories = calculateMacroNutrition(foods: lunchFoods, nutrient: .calories)
            
            let dinnerFoods = foodDailyInput.mealRecord.first { $0.meal == 2 }?.foods
            let dinnerCalories = calculateMacroNutrition(foods: dinnerFoods, nutrient: .calories)
            
            let othersFoods = foodDailyInput.mealRecord.first { $0.meal == 3 }?.foods
            let othersCalories = calculateMacroNutrition(foods: othersFoods, nutrient: .calories)
            
            guard let dietDate = dateFormatter.date(from: foodDailyInput.mealRecord[0].date) else { return }
            let xValue = Double(firstDate.distance(to: dietDate)) / (60 * 60 * 24)
            let entry = BarChartDataEntry(
                x: xValue,
                yValues: [breakfastCalories, lunchCalories, dinnerCalories, othersCalories])
            dataEntries.append(entry)
        }
        configureBarChart(dataEntries: dataEntries, goal: goal)
    }
    
    private func configureBarChart(dataEntries: [BarChartDataEntry], goal: Double) {
        self.legend.enabled = false // 不顯示圖例
        self.scaleYEnabled = false // y軸不能縮放
        self.scaleXEnabled = false // x軸不能縮放
        self.doubleTapToZoomEnabled = false // 雙擊縮放關閉
        self.dragEnabled = false // 啟用拖移手勢
        
        let set = BarChartDataSet(entries: dataEntries, label: "")
        set.colors = [.drYellow, .drGreen, .drOrange, .drDarkBlue]
        set.drawValuesEnabled = false // 不顯示數字
        set.highlightEnabled = false // 選中不改變顏色
        
        let chartData = BarChartData(dataSets: [set])
        chartData.barWidth = 0.6 // 修改立柱的寬度
        self.data = chartData
        self.drawGridBackgroundEnabled = false // 要不要有背景
        self.gridBackgroundColor = .clear // 設定背景顏色
        self.drawBordersEnabled = false // 要不要有邊框
        
        self.xAxis.labelPosition = .bottom // x軸顯示在下方，預設為上方
        self.xAxis.drawGridLinesEnabled = false // 不要有每個x值的線
        self.xAxis.granularity = 1 // x軸的間隔
        self.xAxis.axisMinimum = -0.9
        self.xAxis.axisMaximum = 6.9
        
        self.rightAxis.enabled = false // 不使用右側y軸
        self.leftAxis.drawGridLinesEnabled = false // 不要有每個y值的線
        self.leftAxis.drawLabelsEnabled = false// 不顯示左側y軸文字
        self.leftAxis.drawAxisLineEnabled = false // 不顯示左側y軸線
        self.leftAxis.granularity = 300
        self.leftAxis.axisMinimum = 0 // 最小刻度值
        let dailyCalories: [Double] = dataEntries.compactMap { dataEntry in
            guard let yValues = dataEntry.yValues else { return 0.0 }
            let totalCalories = yValues.reduce(0.0) { $0 + $1 }
            return totalCalories
        }
        guard let maxDailyCalories = dailyCalories.max() else { return }
        if maxDailyCalories > goal {
            self.leftAxis.axisMaximum = maxDailyCalories + 200 // 最大刻度值
        } else {
            self.leftAxis.axisMaximum = goal + 200 // 最大刻度值
        }
        
        let limitLine = ChartLimitLine(limit: goal, label: "\(goal) kcal") // 設定目標線
        limitLine.valueTextColor = UIColor.darkGray  // 文字颜色
        limitLine.valueFont = UIFont.systemFont(ofSize: 12)  // 文字大小
        limitLine.labelPosition = .rightTop // 文字在警戒線的右上
        limitLine.lineWidth = 1 // 線寬
        limitLine.lineColor = .red // 線條顏色
        limitLine.lineDashLengths = [4, 2] // 設定警戒線為虛線
        self.leftAxis.addLimitLine(limitLine)
        self.leftAxis.drawLimitLinesBehindDataEnabled = true // 警戒線在折線圖下
        
    }
}
