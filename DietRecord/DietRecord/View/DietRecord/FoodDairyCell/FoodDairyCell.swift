//
//  FoodDairyCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodDairyCell: UITableViewCell {
    static let reuseIdentifier = "\(FoodDairyCell.self)"
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var foodStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editFoodButton: UIButton!
    
    func layoutCell(foods: [String]) {
        //            guard let calories = Int(food.foodIngredient.nutrientContent.calories)
        //            else { return }
        //            foodView.foodqtyLabel.text = "\(food.qty)份"
        //            foodView.foodNameLabel.text = food.foodIngredient.name
        //            foodView.foodCaloriesLabel.text = "\(food.qty * calories) kcal"
        for food in foods {
            let foodView = FoodBaseView(frame: .zero)
            foodStackView.addArrangedSubview(foodView)
            foodView.translatesAutoresizingMaskIntoConstraints = false
            foodView.foodNameLabel.text = food
        }
        foodStackViewHeightConstraint.isActive = false
        foodStackViewHeightConstraint = foodStackView.heightAnchor.constraint(
            equalToConstant: CGFloat(40 * foods.count)
        )
        foodStackViewHeightConstraint.isActive = true
    }
}
