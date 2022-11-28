//
//  CaloriesPieChartCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import UIKit
import WidgetKit

class CaloriesPieChartCell: UITableViewCell {    
    @IBOutlet weak var caloriesPieChartView: UIView!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var carbsProgressControl: UIProgressView! {
        didSet {
            carbsProgressControl.clipsToBounds = true
            carbsProgressControl.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var protienProgressControl: UIProgressView! {
        didSet {
            protienProgressControl.clipsToBounds = true
            protienProgressControl.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var fatProgressControl: UIProgressView! {
        didSet {
            fatProgressControl.clipsToBounds = true
            fatProgressControl.layer.cornerRadius = 5
        }
    }
    
    weak var controller: DietRecordVC?
    
    func layoutCell(carbs: Double, protein: Double, fat: Double) {
        guard let userData = DRConstant.userData else { return }
        let carbsPersent = carbs / userData.goal[1].transformToDouble()
        let proteinPersent = protein / userData.goal[2].transformToDouble()
        let fatPersent = fat / userData.goal[3].transformToDouble()
        carbsLabel.text = (carbsPersent * 100).format() + "%"
        proteinLabel.text = (proteinPersent * 100).format() + "%"
        fatLabel.text = (fatPersent * 100).format() + "%"
        carbsProgressControl.progress = Float(carbsPersent)
        protienProgressControl.progress = Float(proteinPersent)
        fatProgressControl.progress = Float(fatPersent)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    func setPieChart(breakfast: Double, lunch: Double, dinner: Double, others: Double, goal: Double) {
        let subviews = caloriesPieChartView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let pieChart = PieChart(frame: .zero, superview: caloriesPieChartView)
        pieChart.setCaloriesPieChart(breakfast: breakfast, lunch: lunch, dinner: dinner, others: others, goal: goal)
    }
}
