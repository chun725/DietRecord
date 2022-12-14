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
    @IBOutlet weak var addOrSaveButton: UIButton! {
        didSet {
            addOrSaveButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var nutritionTableView: UITableView! {
        didSet {
            nutritionTableView.dataSource = self
            nutritionTableView.registerCellWithNib(identifier: FoodNutritionCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var tableViewButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var qtyTextFieldBackground: UIView! {
        didSet {
            qtyTextFieldBackground.layer.cornerRadius = 10
        }
    }
    
    var isCollectionCell = false
    var isModify = false
    var newFood: FoodIngredient?
    var chooseFood: Food?
    var food: FoodIngredient?
    var closure: ((Food) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isCollectionCell {
            tableViewButtomConstraint.isActive = false
            tableViewButtomConstraint = nutritionTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            tableViewButtomConstraint.isActive = true
            addOrSaveButton.isHidden = true
            qtyTextFieldBackground.isHidden = true
            foodNameLabel.text = food?.name
        } else {
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
        }
    }
    
    // MARK: - Action -
    @IBAction func addOrSaveFood(sender: Any) {
        guard let food = food,
            let qty = qtyTextField.text
        else { return }
        if !qty.isEmpty {
            let food = Food(qty: qty, foodIngredient: food)
            self.closure?(food)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentInputAlert(title: "????????????????????????")
        }
    }
    
    // MARK: - TableViewDataSource -
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
