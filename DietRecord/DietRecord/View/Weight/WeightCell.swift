//
//  WeightCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/4.
//

import UIKit

class WeightCell: UITableViewCell {
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var increaseView: UIImageView!
    @IBOutlet weak var reduceView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        increaseView.isHidden = false
        reduceView.isHidden = false
    }
    
    func layoutCell(weightData: WeightData) {
        dateLabel.text = dateFormatter.string(from: weightData.date)
        weightLabel.text = weightData.value.format().transform(unit: kgUnit)
        whiteBackgroundView.setShadowAndRadius(radius: 20)
        self.backgroundColor = .clear
    }
}
