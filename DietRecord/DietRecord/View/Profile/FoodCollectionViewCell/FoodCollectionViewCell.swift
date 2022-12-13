//
//  FoodCollectionViewCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/14.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var borderBackground: UIView! {
        didSet {
            borderBackground.setBorder(width: 2, color: .darkGray, radius: 10)
        }
    }
    
    func layoutCell(foodname: String) {
        foodNameLabel.text = foodname
    }
}
