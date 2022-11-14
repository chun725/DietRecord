//
//  FoodDailyCell.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodDailyCell: UITableViewCell {
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var editFoodButton: UIButton!
    @IBOutlet weak var mealChooseButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var photoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var foodsView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    
    weak var controller: DietInputVC?
    var mealRecord: MealRecord?
    
    func layoutCell(foods: [Food]) {
        if let mealRecord = mealRecord {
            dateTextField.text = mealRecord.date
            mealTextField.text = Meal.allCases[mealRecord.meal].rawValue
            mealImageView.loadImage(mealRecord.imageURL)
            commentTextView.text = mealRecord.comment
            switchButton.isOn = mealRecord.isShared
        }
        if foods.isEmpty {
            photoTopConstraint.constant = 24
            foodsView.isHidden = true
        } else {
            photoTopConstraint.constant = CGFloat(102 + foods.count * 40)
            foodsView.isHidden = false
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
        foodsView.setShadowAndRadius(radius: 10)
        
        switchButton.tintColor = .drGray
        switchButton.onTintColor = .drYellow
        switchButton.addTarget(self, action: #selector(changeShared), for: .valueChanged)
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let chooseDatePage = storyboard.instantiateViewController(withIdentifier: "\(ChooseDateVC.self)")
            as? ChooseDateVC {
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
