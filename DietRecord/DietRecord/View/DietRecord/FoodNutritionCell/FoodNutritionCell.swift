//
//  FoodNutritionCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

class FoodNutritionCell: UITableViewCell {
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var monounsaturatedLabel: UILabel!
    @IBOutlet weak var polyunsaturatedLabel: UILabel!
    @IBOutlet weak var cholesterolLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var potassiumLabel: UILabel!
    @IBOutlet weak var grayBackgroundView: UIView!
    
    func layoutCell(food: FoodIngredient) {
        let nutrition = food.nutrientContent
        servingSizeLabel.text = "\(food.weightPerUnit)克"
        caloriesLabel.text = nutrition.calories.transform(unit: kcalUnit)
        carbsLabel.text = nutrition.carbohydrate.transform(unit: gUnit)
        fiberLabel.text = nutrition.dietaryFiber.transform(unit: gUnit)
        sugarLabel.text = nutrition.sugar.transform(unit: gUnit)
        proteinLabel.text = nutrition.protein.transform(unit: gUnit)
        fatLabel.text = nutrition.lipid.transform(unit: gUnit)
        saturatedFatLabel.text = nutrition.saturatedLipid.transform(unit: gUnit)
        monounsaturatedLabel.text = nutrition.monounsaturatedLipid.transform(unit: mgUnit)
        polyunsaturatedLabel.text = nutrition.polyunsaturatedLipid.transform(unit: mgUnit)
        cholesterolLabel.text = nutrition.cholesterol.transform(unit: mgUnit)
        sodiumLabel.text = nutrition.sodium.transform(unit: mgUnit)
        potassiumLabel.text = nutrition.potassium.transform(unit: mgUnit)
        grayBackgroundView.setShadowAndRadius(radius: 0)
    }
}
