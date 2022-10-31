//
//  FoodNutrtionVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodNutritionVC: UIViewController {
    @IBOutlet weak var foodNameLabel: UILabel!
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
    @IBOutlet weak var qtyTextField: UITextField!
    
    var food: FoodIngredient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNutritionInformation()
    }
    
    func configureNutritionInformation() {
        foodNameLabel.text = food?.name
        guard let servingSize = food?.weightPerUnit,
            let nutrition = food?.nutrientContent else { return }
        servingSizeLabel.text = "\(servingSize)克"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func goBackToFoodSearchVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func addFood(_ sender: Any) {
    }
}
