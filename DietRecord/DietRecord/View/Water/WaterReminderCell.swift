//
//  WaterReminderCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class WaterReminderCell: UITableViewCell {
    @IBOutlet weak var reminderBackgroundView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var reminderTimeLabel: UILabel!
    
    func layoutCell(time: String) {
        reminderBackgroundView.setShadowAndRadius(radius: 10)
        reminderTimeLabel.text = time
    }
}
