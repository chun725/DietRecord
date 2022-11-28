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
    @IBOutlet weak var commentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var commentLabelButtomConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodStackViewHeightConstraint.constant = 0
        let subviews = foodStackView.arrangedSubviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        commentLabel.text = ""
        caloriesLabel.isHidden = true
        mealImage.image = nil
    }
    
    func layoutCell(mealRecord: MealRecord?) {
        mealImage.layer.cornerRadius = 10
        whiteBackgroundView.setShadowAndRadius(radius: 10)
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
            caloriesLabel.isHidden = false
            caloriesLabel.text = DRConstant.calculateMacroNutrition(
                foods: mealRecord.foods,
                nutrient: .calories)
            .format()
            .transform(
                unit: Units.kcalUnit.rawValue)
            foodStackViewHeightConstraint.constant = CGFloat(mealRecord.foods.count * 40)
            if let imageURL = mealRecord.imageURL {
                mealImage.loadImage(imageURL)
                commentTopConstraint.constant = 202
                self.presentView(views: [photoTitleLabel, mealImage])
            } else {
                commentTopConstraint.constant = 8
                self.hiddenView(views: [photoTitleLabel, mealImage])
            }
            
            if !mealRecord.comment.isEmpty {
                commentLabel.text = mealRecord.comment
                commentButtomConstraint.constant = 36
                commentLabelButtomConstraint.constant = 16
                self.presentView(views: [commentLabel, commentTitleLabel])
            } else if mealRecord.comment.isEmpty && mealRecord.imageURL != nil {
                commentButtomConstraint.constant = 0
                commentLabelButtomConstraint.constant = 16
                self.hiddenView(views: [commentLabel, commentTitleLabel])
            } else {
                commentButtomConstraint.constant = 0
                commentLabelButtomConstraint.constant = 0
                self.hiddenView(views: [commentLabel, commentTitleLabel])
            }
        }
    }
}
