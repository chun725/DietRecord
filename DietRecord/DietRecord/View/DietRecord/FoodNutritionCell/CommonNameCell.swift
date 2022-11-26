//
//  CommonNameCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit
import Lottie

class CommonNameCell: UITableViewCell {
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    func layoutCell(food: FoodIngredient) {
        if !food.commonName.isEmpty {
            let commonName = food.commonName.split(separator: ",")
            let newCommonName = commonName.joined(separator: "、")
            commonNameLabel.text = "俗名：" + newCommonName
            animationView.loopMode = .loop
            animationView.animationSpeed = 1.25
            animationView.play()
        }
    }
}
