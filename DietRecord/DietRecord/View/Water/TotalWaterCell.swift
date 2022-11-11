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
    @IBOutlet weak var addReminderButton: UIButton!
    
    weak var controller: WaterVC?
    
    func layoutCell(water: Double, goal: Double) {
        waterCurrentLabel.text = water.formatNoPoint().transform(unit: mLUnit)
        if goal != 0.0 {
            percentLabel.text = (water / goal * 100).format() + "%"
        }
        whiteBackgroundView.setShadowAndRadius(radius: 10)
        self.backgroundColor = .clear
        let subviews = waterPieChartView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let pieChart = PieChart(frame: .zero, superview: waterPieChartView)
        pieChart.setWaterPieChart(water: water, goal: goal)
        guard let userData = userData else { return }
        waterGoalLabel.text = "目標飲水量 " + userData.waterGoal.transform(unit: mLUnit)
    }
    
    @IBAction func goToChangeGoalPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: water, bundle: nil)
        if let waterInputPage = storyboard.instantiateViewController(withIdentifier: "\(WaterInputVC.self)")
            as? WaterInputVC {
            waterInputPage.isGoalInput = true
            waterInputPage.closure = { [weak self] waterGoal in
                self?.controller?.waterGoal = waterGoal
            }
            controller?.present(waterInputPage, animated: false)
        }
    }
}
