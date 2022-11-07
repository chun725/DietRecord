//
//  ProfileResponseCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import UIKit

class ProfileResponseCell: UITableViewCell {
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    func layoutCell(response: Response) {
        self.backgroundColor = .clear
        responseLabel.text = response.response
    }
}
