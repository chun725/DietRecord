//
//  FoodBaseView.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import UIKit

class FoodBaseView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var foodqtyLabel: UILabel!
    @IBOutlet weak var foodCaloriesLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        Bundle.main.loadNibNamed(DRConstant.foodBaseView, owner: self)
        stickSubview(contentView)
    }
    
    func layoutView(name: String, qty: String, calories: String) {
        foodqtyLabel.text = qty.transform(unit: Units.gUnit.rawValue)
        foodNameLabel.text = name
        let calories = qty.transformToDouble() / 100 * calories.transformToDouble()
        foodCaloriesLabel.text = calories.format().transform(unit: Units.kcalUnit.rawValue)
    }
}
