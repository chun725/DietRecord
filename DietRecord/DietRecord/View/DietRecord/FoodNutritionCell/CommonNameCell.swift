//
//  CommonNameCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

class CommonNameCell: UITableViewCell {
    @IBOutlet weak var commonNameLabel: UILabel!
    
    func layoutCell(food: FoodIngredient) {
        if !food.commonName.isEmpty {
            let commonName = food.commonName.split(separator: ",")
            let newCommonName = commonName.joined(separator: "、")
            commonNameLabel.text = newCommonName
        }
    }
}
