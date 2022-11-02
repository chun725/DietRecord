//
//  DietRecoedCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import UIKit

class DietRecordCell: UITableViewCell {
    @IBOutlet weak var foodStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodStackViewHeightConstraint.isActive = false
        foodStackViewHeightConstraint = foodStackView.heightAnchor.constraint(
            equalToConstant: CGFloat(0)
        )
        foodStackViewHeightConstraint.isActive = true
        let subviews = foodStackView.arrangedSubviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        commentLabel.text = "Comment"
        caloriesLabel.isHidden = true
        mealImage.image = nil
    }
    
    func layoutCell(mealRecord: MealRecord?) {
        mealLabel.clipsToBounds = true
        mealLabel.layer.cornerRadius = 10
        if let mealRecord = mealRecord {
            for food in mealRecord.foods {
                let foodView = FoodBaseView(frame: .zero)
                foodStackView.addArrangedSubview(foodView)
                foodView.translatesAutoresizingMaskIntoConstraints = false
                foodView.layoutView(
                    name: food.foodIngredient.name,
                    qty: food.qty,
                    calories: food.foodIngredient.nutrientContent.calories)
            }
            foodStackViewHeightConstraint.isActive = false
            foodStackViewHeightConstraint = foodStackView.heightAnchor.constraint(
                equalToConstant: CGFloat(40 * mealRecord.foods.count)
            )
            foodStackViewHeightConstraint.isActive = true
            caloriesLabel.isHidden = false
            caloriesLabel.text = calculateMacroNutrition(
                foods: mealRecord.foods,
                nutrient: .calories).format().transform(unit: kcalUnit)
            commentLabel.text = mealRecord.comment
            mealImage.loadImage(mealRecord.imageURL, placeHolder: UIImage(named: "Image_Placeholder"))
        }
    }
}
