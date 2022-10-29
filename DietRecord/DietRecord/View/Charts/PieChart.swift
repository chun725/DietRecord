//
//  PieChart.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import Foundation
import Charts

class PieChart: PieChartView {
    
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
            self.heightAnchor.constraint(equalToConstant: 200)])
    }
    
    func setCaloriesPieChart(breakfast: Double, lunch: Double, dinner: Double, others: Double, goal: Double ) {
        
        let gap = goal - (breakfast + lunch + dinner + others)
        
        let pieChartDataEntries: [PieChartDataEntry] = [
            PieChartDataEntry(value: breakfast, label: "早餐"),
            PieChartDataEntry(value: lunch, label: "午餐"),
            PieChartDataEntry(value: dinner, label: "晚餐"),
            PieChartDataEntry(value: others, label: "其他"),
            PieChartDataEntry(value: gap, label: "差距")
        ]
        
        let set = PieChartDataSet(entries: pieChartDataEntries, label: "")
        set.colors = [UIColor.Yellow, UIColor.Green, UIColor.Orange, UIColor.DarkBlue, UIColor.Gray]
        
        let consumed = (goal - gap) / goal * 100
        configurePieChart(set: set, consumed: consumed)
        
    }
    
    func setWaterPieChart(water: Double, goal: Double) {
        
        let gap = goal - water
        
        let pieChartDataEntries: [PieChartDataEntry] = [
            PieChartDataEntry(value: water, label: "目前飲水量"),
            PieChartDataEntry(value: gap, label: "與目標的差異")
        ]
        
        let set = PieChartDataSet(entries: pieChartDataEntries, label: "")
        set.colors = [UIColor.Blue, UIColor.Gray]
        
        let consumed = water / goal * 100
        configurePieChart(set: set, consumed: consumed)
    }
    
    private func configurePieChart(set: PieChartDataSet, consumed: Double) {
        
        set.selectionShift = 0
        set.sliceSpace = 3
        set.drawValuesEnabled = false // 在圓餅圖上不顯示數值
        
        let data = PieChartData(dataSet: set)
        data.setValueTextColor(UIColor.clear)

        self.data = data
        self.holeColor = .clear // 空心位置的背景顏色
        self.centerText = consumed.format(f: ".1") + "%" // 設定空心位置的文字
        
        let legend = self.legend
        legend.form = .circle
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
    }
    
}
