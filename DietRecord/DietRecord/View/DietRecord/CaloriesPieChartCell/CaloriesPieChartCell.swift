//
//  CaloriesPieChartCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import UIKit

class CaloriesPieChartCell: UITableViewCell {    
    @IBOutlet weak var caloriesPieChartView: UIView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    
    
    func layoutCell(calories: String, carbs: String, protein: String, fat: String) {
        caloriesLabel.text = calories
        carbsLabel.text = carbs
        proteinLabel.text = protein
        fatLabel.text = fat
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
