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
        Bundle.main.loadNibNamed(foodBaseView, owner: self)
        stickSubview(contentView)
    }
}
