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
    @IBOutlet weak var foodStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editFoodButton: UIButton!
    @IBOutlet weak var mealChooseButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    
    weak var controller: DietInputVC?
    
    func layoutCell(foods: [Food]) {
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
        foodStackViewHeightConstraint.isActive = false
        foodStackViewHeightConstraint = foodStackView.heightAnchor.constraint(
            equalToConstant: CGFloat(40 * foods.count)
        )
        foodStackViewHeightConstraint.isActive = true
        mealTextField.isUserInteractionEnabled = false
        dateTextField.isUserInteractionEnabled = false
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
}
