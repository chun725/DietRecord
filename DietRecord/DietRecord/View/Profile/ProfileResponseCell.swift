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
    
    let profileProvider = ProfileProvider()
    
    func layoutCell(response: Response) {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        self.backgroundColor = .clear
        responseLabel.text = response.response
        profileProvider.fetchUserData(userID: response.person) { result in
            switch result {
            case .success(let user):
                self.usernameLabel.text = user.username
                self.userImageView.loadImage(user.userImageURL)
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
}
