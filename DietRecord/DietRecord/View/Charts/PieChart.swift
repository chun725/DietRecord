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
        self.rotationEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
        configureConstraint(superview: superview)
    }
    
    private func configureConstraint(superview: UIView) {
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 1),
            self.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setCaloriesPieChart(breakfast: Double, lunch: Double, dinner: Double, others: Double, goal: Double ) {
        self.setExtraOffsets(left: 5, top: 5, right: 5, bottom: 5) // 讓圓餅圖周圍有邊界
        
        let gap = goal - (breakfast + lunch + dinner + others)
        
        let pieChartDataEntries: [PieChartDataEntry] = [
            PieChartDataEntry(value: breakfast, label: Meal.breakfast.rawValue),
            PieChartDataEntry(value: lunch, label: Meal.lunch.rawValue),
            PieChartDataEntry(value: dinner, label: Meal.dinner.rawValue),
            PieChartDataEntry(value: others, label: Meal.others.rawValue),
            PieChartDataEntry(value: gap, label: Meal.gap.rawValue)
        ]
        
        let set = PieChartDataSet(entries: pieChartDataEntries, label: "")
        set.colors = [UIColor.drYellow, UIColor.drGreen, UIColor.drOrange, UIColor.drDarkBlue, UIColor.drGray]
        
        let consumed = (goal - gap) / goal * 100
        configurePieChart(set: set, consumed: consumed)
        
        guard let font = UIFont(name: fontName, size: 8) else { return }
        self.legend.font = font
    }
    
    func setWaterPieChart(water: Double, goal: Double) {
        self.setExtraOffsets(left: 8, top: 8, right: 8, bottom: 0) // 讓圓餅圖周圍有邊界
        let gap = goal - water
        
        let pieChartDataEntries: [PieChartDataEntry] = [
            PieChartDataEntry(value: water, label: Water.current.rawValue),
            PieChartDataEntry(value: gap, label: Water.gap.rawValue)
        ]
        
        let set = PieChartDataSet(entries: pieChartDataEntries, label: "")
        set.colors = [UIColor.drBlue, UIColor.drGray]
        
        let consumed = water / goal * 100
        configurePieChart(set: set, consumed: consumed)
        
        guard let font = UIFont(name: fontName, size: 12) else { return }
        self.legend.font = font
    }
    
    private func configurePieChart(set: PieChartDataSet, consumed: Double) {
        set.selectionShift = 0
        set.sliceSpace = 3
        set.drawValuesEnabled = false // 在圓餅圖上不顯示數值
        
        let data = PieChartData(dataSet: set)
        data.setValueTextColor(UIColor.clear)

        self.data = data
        self.holeColor = .clear // 空心位置的背景顏色
        self.backgroundColor = .clear // 背景為透明
        self.centerText = consumed.format() + "%" // 設定空心位置的文字

        let legend = self.legend
        legend.form = .circle
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.textColor = UIColor.drDarkGray
    }
}
