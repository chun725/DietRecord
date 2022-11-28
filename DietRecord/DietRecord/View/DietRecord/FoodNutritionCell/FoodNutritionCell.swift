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
    @IBOutlet weak var nutritionLabel: UILabel!
    
    func layoutCell(food: FoodIngredient) {
        let nutrition = food.nutrientContent
        servingSizeLabel.text = "\(food.weightPerUnit)克"
        caloriesLabel.text = nutrition.calories.transform(unit: Units.kcalUnit.rawValue)
        carbsLabel.text = nutrition.carbohydrate.transform(unit: Units.gUnit.rawValue)
        fiberLabel.text = nutrition.dietaryFiber.transform(unit: Units.gUnit.rawValue)
        sugarLabel.text = nutrition.sugar.transform(unit: Units.gUnit.rawValue)
        proteinLabel.text = nutrition.protein.transform(unit: Units.gUnit.rawValue)
        fatLabel.text = nutrition.lipid.transform(unit: Units.gUnit.rawValue)
        saturatedFatLabel.text = nutrition.saturatedLipid.transform(unit: Units.gUnit.rawValue)
        monounsaturatedLabel.text = nutrition.monounsaturatedLipid.transform(unit: Units.mgUnit.rawValue)
        polyunsaturatedLabel.text = nutrition.polyunsaturatedLipid.transform(unit: Units.mgUnit.rawValue)
        cholesterolLabel.text = nutrition.cholesterol.transform(unit: Units.mgUnit.rawValue)
        sodiumLabel.text = nutrition.sodium.transform(unit: Units.mgUnit.rawValue)
        potassiumLabel.text = nutrition.potassium.transform(unit: Units.mgUnit.rawValue)
        grayBackgroundView.setShadowAndRadius(radius: 10)
        nutritionLabel.layer.cornerRadius = 10
    }
}
