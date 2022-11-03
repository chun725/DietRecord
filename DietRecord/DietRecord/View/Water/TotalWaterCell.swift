//
//  TotalWaterCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class TotalWaterCell: UITableViewCell {
    @IBOutlet weak var waterCurrentLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var addWaterButton: UIButton!
    @IBOutlet weak var waterPieChartView: UIView!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var changeGoalButton: UIButton!
    @IBOutlet weak var addReminderButton: UIButton!
    
    func layoutCell(water: Double, goal: Double) {
        waterCurrentLabel.text = water.formatNoPoint().transform(unit: mLUnit)
        percentLabel.text = (water / goal * 100).format() + "%"
        whiteBackgroundView.layer.cornerRadius = 20
        self.backgroundColor = .clear
        let subviews = waterPieChartView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let pieChart = PieChart(frame: .zero, superview: waterPieChartView)
        pieChart.setWaterPieChart(water: water, goal: goal)
    }
}
