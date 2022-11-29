//
//  ReportDetailCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/2.
//

import UIKit

class ReportDetailCell: UITableViewCell {
    @IBOutlet weak var caloriesCurrentLabel: UILabel!
    @IBOutlet weak var carbsCurrentLabel: UILabel!
    @IBOutlet weak var fiberCurrentLabel: UILabel!
    @IBOutlet weak var sugarCurrentLabel: UILabel!
    @IBOutlet weak var proteinCurrentLabel: UILabel!
    @IBOutlet weak var fatCurrentLabel: UILabel!
    @IBOutlet weak var saturatedFatCurrentLabel: UILabel!
    @IBOutlet weak var monounsaturatedFatCurrentLabel: UILabel!
    @IBOutlet weak var polyunsaturatedFatCurrentLabel: UILabel!
    @IBOutlet weak var cholesterolCurrentLabel: UILabel!
    @IBOutlet weak var sodiumCurrentLabel: UILabel!
    @IBOutlet weak var potassiumCurrentLabel: UILabel!
    
    @IBOutlet weak var grayBackgroundView: UIView!
    
    @IBOutlet weak var caloriesGoalLabel: UILabel!
    @IBOutlet weak var carbsGoalLabel: UILabel!
    @IBOutlet weak var fiberGoalLabel: UILabel!
    @IBOutlet weak var sugarGoalLabel: UILabel!
    @IBOutlet weak var proteinGoalLabel: UILabel!
    @IBOutlet weak var fatGoalLabel: UILabel!
    @IBOutlet weak var saturatedFatGoalLabel: UILabel!
    @IBOutlet weak var monounsaturatedFatGoalLabel: UILabel!
    @IBOutlet weak var polyunsaturatedFatGoalLabel: UILabel!
    @IBOutlet weak var cholesterolGoalLabel: UILabel!
    @IBOutlet weak var sodiumGoalLabel: UILabel!
    @IBOutlet weak var potassiumGoalLabel: UILabel!
    
    func layoutCell(foodDailyInputs: [FoodDailyInput]?) {
        grayBackgroundView.setShadowAndRadius(radius: 10)
        guard let foodDailyInputs = foodDailyInputs else { return }
        let totalFoods = foodDailyInputs.flatMap { $0.mealRecord }.flatMap { $0.foods }
        self.caloriesCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .calories)
        .format()
        self.carbsCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .carbohydrate)
        .format()
        self.fiberCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .dietaryFiber)
        .format()
        self.sugarCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .sugar)
        .format()
        self.proteinCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .protein)
        .format()
        self.fatCurrentLabel.text = DRConstant.calculateMacroNutrition(
            foods: totalFoods,
            nutrient: .lipid)
        .format()
        self.saturatedFatCurrentLabel.text = DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .saturatedLipid)
        .format()
        self.monounsaturatedFatCurrentLabel.text = (DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .monounsaturatedLipid) / 1000)
        .format()
        self.polyunsaturatedFatCurrentLabel.text = (DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .polyunsaturatedLipid) / 1000)
        .format()
        self.cholesterolCurrentLabel.text = (DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .cholesterol) / 1000)
        .format()
        self.sodiumCurrentLabel.text = (DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .sodium) / 1000)
        .format()
        self.potassiumCurrentLabel.text = (DRConstant.calculateMicroNutrition(
            foods: totalFoods,
            nutrient: .potassium) / 1000)
        .format()
    }
    
    func layoutOfGoal(goal: [String]) {
        self.caloriesGoalLabel.text = (goal[0].transformToDouble() * 7).format()
        self.carbsGoalLabel.text = (goal[1].transformToDouble() * 7).format()
        self.proteinGoalLabel.text = (goal[2].transformToDouble() * 7).format()
        self.fatGoalLabel.text = (goal[3].transformToDouble() * 7).format()
//        self.fiberGoalLabel.text = (goal.dietaryFiber.transformToDouble() * 7).format()
//        self.sugarGoalLabel.text = (goal.sugar.transformToDouble() * 7).format()
//        self.saturatedFatGoalLabel.text = (goal.lipid.transformToDouble() * 7).format()
//        self.monounsaturatedFatGoalLabel.text = (goal.monounsaturatedLipid.transformToDouble() * 7 / 1000).format()
//        self.polyunsaturatedFatGoalLabel.text = (goal.polyunsaturatedLipid.transformToDouble() * 7 / 1000).format()
//        self.cholesterolGoalLabel.text = (goal.cholesterol.transformToDouble() * 7 / 1000).format()
//        self.sodiumGoalLabel.text = (goal.sodium.transformToDouble() * 7 / 1000).format()
//        self.potassiumGoalLabel.text = (goal.potassium.transformToDouble() * 7 / 1000).format()
    }
}
