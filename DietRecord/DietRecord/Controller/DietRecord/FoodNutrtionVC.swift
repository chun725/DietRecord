//
//  FoodNutrtionVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodNutritionVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var addOrSaveButton: UIButton!
    @IBOutlet weak var nutritionTableView: UITableView!
    
    var isModify = false
    var newFood: FoodIngredient?
    var chooseFood: Food?
    var food: FoodIngredient?
    var closure: ((Food) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isModify {
            addOrSaveButton.setTitle("Save", for: .normal)
            guard let chooseFood = chooseFood else { return }
            qtyTextField.text = chooseFood.qty
            foodNameLabel.text = chooseFood.foodIngredient.name
            food = chooseFood.foodIngredient
        } else {
            guard let newFood = newFood else { return }
            foodNameLabel.text = newFood.name
            food = newFood
        }
        nutritionTableView.dataSource = self
        nutritionTableView.registerCellWithNib(identifier: FoodNutritionCell.reuseIdentifier, bundle: nil)
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
    
    @IBAction func addOrSaveFood(sender: Any) {
        guard let food = food,
            let qty = qtyTextField.text
        else { return }
        if !qty.isEmpty {
            let food = Food(qty: qty, foodIngredient: food)
            self.closure?(food)
            self.navigationController?.popViewController(animated: false)
        } else {
            self.presentInputAlert()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let food = food else { fatalError("Could not find food.") }
        if food.commonName.isEmpty {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let food = food else { fatalError("Could not find food.") }
        if food.commonName.isEmpty || indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FoodNutritionCell.reuseIdentifier, for: indexPath) as? FoodNutritionCell
            else { fatalError("Could not create the food nutrition cell.") }
            cell.layoutCell(food: food)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommonNameCell.reuseIdentifier, for: indexPath) as? CommonNameCell
            else { fatalError("Could not create the commonname cell.") }
            cell.layoutCell(food: food)
            return cell
        }
    }
}
