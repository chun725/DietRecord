//
//  FoodSearchResultCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchResultCell: UITableViewCell {
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    func layoutResultCell(food: FoodIngredient) {
        foodNameLabel.text = food.name
        qtyLabel.text = "1份, \(food.weightPerUnit)克"
        caloriesLabel.text = "\(food.nutrientContent.calories.transformToDouble().format()) kcal / 100 克"
    }
    
    func layoutChooseCell(food: Food) {
        foodNameLabel.text = food.foodIngredient.name
        qtyLabel.text = food.qty.transform(unit: Units.gUnit.rawValue)
        let calories = food.qty.transformToDouble() / 100 *
        food.foodIngredient.nutrientContent.calories.transformToDouble()
        caloriesLabel.text = calories.format().transform(unit: Units.kcalUnit.rawValue)
    }
}
