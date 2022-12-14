//
//  TotalWaterCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class TotalWaterCell: UITableViewCell {
    @IBOutlet weak var whiteBackgroundView: UIView! {
        didSet {
            whiteBackgroundView.setShadowAndRadius(radius: 10)
        }
    }
    @IBOutlet weak var waterCurrentLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var addWaterButton: UIButton!
    @IBOutlet weak var waterPieChartView: UIView!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var addReminderButton: UIButton!
    
    weak var controller: WaterVC?
    
    func layoutCell(water: Double, goal: Double) {
        waterCurrentLabel.text = water.formatNoPoint().transform(unit: Units.mLUnit.rawValue)
        if goal != 0.0 {
            percentLabel.text = (water / goal * 100).format() + "%"
        }
        self.backgroundColor = .clear
        let subviews = waterPieChartView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let pieChart = PieChart(frame: .zero, superview: waterPieChartView)
        pieChart.setWaterPieChart(water: water, goal: goal)
        controller?.pieChartView = pieChart
        guard let userData = DRConstant.userData else { return }
        waterGoalLabel.text = "目標飲水量 " + userData.waterGoal.transform(unit: Units.mLUnit.rawValue)
    }
    
    @IBAction func goToChangeGoalPage(_ sender: Any) {
        if let waterInputPage = UIStoryboard.water.instantiateViewController(
            withIdentifier: WaterInputVC.reuseIdentifier) as? WaterInputVC {
            waterInputPage.isGoalInput = true
            waterInputPage.closure = { [weak self] waterGoal in
                self?.controller?.waterGoal = waterGoal
                self?.controller?.waterTableView.reloadData()
                self?.controller?.waterTableView.layoutIfNeeded()
                self?.controller?.changeImage()
            }
            controller?.present(waterInputPage, animated: false)
        }
    }
}
