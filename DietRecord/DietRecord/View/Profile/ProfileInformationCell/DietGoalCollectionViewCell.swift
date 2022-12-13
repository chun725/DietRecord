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
    @IBOutlet weak var grayBackgroundView: UIView! {
        didSet {
            grayBackgroundView.setBorder(width: 1, color: .drDarkGray, radius: 5)
        }
    }
    
    func layoutCell(row: Int, goal: String) {
        titleLabel.text = MacroNutrient.allCases[row].rawValue
        let unit = row == 0 ? Units.kcalUnit.rawValue : Units.gUnit.rawValue
        goalLabel.text = goal.transform(unit: unit)
    }
}
