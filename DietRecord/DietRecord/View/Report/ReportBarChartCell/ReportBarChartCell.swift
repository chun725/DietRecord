//
//  ReportBarChart.swift
//  DietRecord
//
//  Created by chun on 2022/11/2.
//

import UIKit

class ReportBarChartCell: UITableViewCell {
    @IBOutlet weak var barChartView: UIView!
    
    func setBarChart(date: String, foodDailyInputs: [FoodDailyInput]?, goal: Double) {
        self.backgroundColor = .clear
        let subviews = barChartView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let barChart = BarChart(frame: .zero, superview: barChartView)
        barChart.setReportBarChart(date: date, foodDailyInputs: foodDailyInputs, goal: goal)
    }
}
