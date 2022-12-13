//
//  WeightCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/4.
//

import UIKit

class WeightCell: UITableViewCell {
    @IBOutlet weak var whiteBackgroundView: UIView! {
        didSet {
            whiteBackgroundView.setShadowAndRadius(radius: 10)
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var increaseView: UIImageView!
    @IBOutlet weak var reduceView: UIImageView!
    @IBOutlet weak var flatView: UIView! {
        didSet {
            flatView.layer.cornerRadius = 2
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        increaseView.isHidden = false
        reduceView.isHidden = false
        flatView.isHidden = false
    }
    
    func layoutCell(weightData: WeightData) {
        dateLabel.text = DRConstant.dateFormatter.string(from: weightData.date)
        weightLabel.text = weightData.value.format().transform(unit: Units.kgUnit.rawValue)
        self.backgroundColor = .clear
    }
}
