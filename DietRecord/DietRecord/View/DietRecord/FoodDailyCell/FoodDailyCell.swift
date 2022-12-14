//
//  FoodDailyCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodDailyCell: UITableViewCell {
    @IBOutlet weak var mealImageView: UIImageView! {
        didSet {
            mealImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
            commentTextView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var foodsView: UIView! {
        didSet {
            foodsView.setShadowAndRadius(radius: 10)
        }
    }
    @IBOutlet weak var switchButton: UISwitch! {
        didSet {
            switchButton.tintColor = .drGray
            switchButton.onTintColor = .drYellow
            switchButton.addTarget(self, action: #selector(changeShared), for: .valueChanged)
        }
    }
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var editFoodButton: UIButton!
    @IBOutlet weak var mealChooseButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var photoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodStackViewHeightConstraint: NSLayoutConstraint!
    
    weak var controller: DietInputVC?
    var mealRecord: MealRecord?
    
    func layoutCell(foods: [Food]) {
        if let mealRecord = mealRecord {
            dateTextField.text = mealRecord.date
            mealTextField.text = Meal.allCases[mealRecord.meal].rawValue
            mealImageView.loadImage(mealRecord.imageURL)
            commentTextView.text = mealRecord.comment
            switchButton.setOn(mealRecord.isShared, animated: false)
            controller?.isShared = mealRecord.isShared
        }
        if foods.isEmpty {
            photoTopConstraint.constant = 24
            foodsView.isHidden = true
        } else {
            photoTopConstraint.constant = CGFloat(102 + foods.count * 40)
            foodsView.isHidden = false
            foodStackViewHeightConstraint.constant = CGFloat(foods.count * 40)
        }
        
        let subviews = foodStackView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        for food in foods {
            let foodView = FoodBaseView(frame: .zero)
            foodStackView.addArrangedSubview(foodView)
            foodView.translatesAutoresizingMaskIntoConstraints = false
            foodView.layoutView(
                name: food.foodIngredient.name,
                qty: food.qty,
                calories: food.foodIngredient.nutrientContent.calories)
        }
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        if let chooseDatePage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: ChooseDateVC.reuseIdentifier) as? ChooseDateVC {
            chooseDatePage.closure = { [weak self] date in
                self?.dateTextField.text = date
            }
            controller?.present(chooseDatePage, animated: false)
        }
    }
    
    @objc func changeShared(sender: UISwitch) {
        if sender.isOn {
            controller?.isShared = true
        } else {
            controller?.isShared = false
        }
    }
}
