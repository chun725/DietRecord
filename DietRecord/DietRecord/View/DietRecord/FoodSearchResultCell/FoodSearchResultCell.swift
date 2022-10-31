//
//  FoodSearchResultCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchResultCell: UITableViewCell {
    static let reuseidentifier = "\(FoodSearchResultCell.self)"
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    func layoutCell(food: FoodIngredient) {
        foodNameLabel.text = food.name
        qtyLabel.text = "1份, \(food.weightPerUnit)克"
        caloriesLabel.text = "\(food.nutrientContent.calories.transformToDouble().format(f: ".1")) kcal / 100 克"
    }
}
