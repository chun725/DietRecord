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
        Bundle.main.loadNibNamed("FoodBaseView", owner: self)
        contentView.removeFromSuperview()
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("FoodBaseView", owner: self)
    }
}
