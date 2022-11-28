//
//  DietGoalCollectionViewCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/15.
//

import UIKit

class DietGoalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var grayBackgroundView: UIView!
    
    func layoutCell(row: Int, goal: String) {
        titleLabel.text = MacroNutrient.allCases[row].rawValue
        if row == 0 {
            goalLabel.text = goal.transform(unit: Units.kcalUnit.rawValue)
        } else {
            goalLabel.text = goal.transform(unit: Units.gUnit.rawValue)
        }
        grayBackgroundView.setBorder(width: 1, color: .drDarkGray, radius: 5)
    }
}
