//
//  WaterReminderCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class WaterReminderCell: UITableViewCell {
    @IBOutlet weak var reminderBackgroundView: UIView! {
        didSet {
            reminderBackgroundView.setShadowAndRadius(radius: 10)
        }
    }
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    
    func layoutCell(time: String) {
        let timeString = time.components(separatedBy: ":")
        guard let hour = Int(timeString[0]) else { return }
        timeImageView.image = hour < 18 && hour >= 6 ? UIImage(named: "Image_Sun") : UIImage(named: "Image_Night")
        reminderTimeLabel.text = time
    }
}
