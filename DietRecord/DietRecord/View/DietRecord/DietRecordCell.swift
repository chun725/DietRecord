//
//  DietRecoedCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import UIKit

class DietRecordCell: UITableViewCell {
    
    static let reuseIdentifier = "\(DietRecordCell.self)"
    @IBOutlet weak var foodStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var foodStackView: UIStackView!
    
    func layoutCell(foods: [String], photo: String, comment: String) {
        for food in foods {
            let foodView = FoodBaseView(frame: .zero)
//            guard let calories = Int(food.foodIngredient.nutrientContent.calories)
//            else { return }
//            foodView.foodqtyLabel.text = "\(food.qty)份"
//            foodView.foodNameLabel.text = food.foodIngredient.name
//            foodView.foodCaloriesLabel.text = "\(food.qty * calories) kcal"
            foodStackView.addArrangedSubview(foodView)
            foodView.translatesAutoresizingMaskIntoConstraints = false
            foodView.foodNameLabel.text = food
        }
        foodStackViewHeightConstraint.isActive = false
        foodStackViewHeightConstraint = foodStackView.heightAnchor.constraint(equalToConstant: CGFloat(40 * foods.count))
        foodStackViewHeightConstraint.isActive = true
        mealLabel.clipsToBounds = true
        mealLabel.layer.cornerRadius = 10
        commentLabel.text = comment
    }
}
