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
    @IBOutlet weak var timeLabel: UILabel!
    
    func layoutCell(time: String) {
        self.backgroundColor = .clear
        reminderBackgroundView.layer.cornerRadius = 5
        timeLabel.text = time
    }
}
