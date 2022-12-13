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
    @IBOutlet weak var goToUserPageButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.usernameLabel.alpha = 0
        self.userImageView.alpha = 0
        self.responseLabel.alpha = 0
    }
    
    var otherUserID: String?
    weak var controller: UIViewController?
    
    func layoutCell(response: Response) {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        self.backgroundColor = .clear
        responseLabel.text = response.response
        self.otherUserID = response.person
        FirebaseManager.shared.fetchUserData(userID: response.person) { [weak self] userData in
            guard let self = self else { return }
            if let userData = userData {
                self.goToUserPageButton.isEnabled = true
                self.usernameLabel.text = userData.username
                self.userImageView.loadImage(userData.userImageURL)
            } else {
                self.usernameLabel.text = "Unknown"
                self.goToUserPageButton.isEnabled = false
            }
            UIView.animate(withDuration: 0.5) {
                self.usernameLabel.alpha = 1
                self.userImageView.alpha = 1
                self.responseLabel.alpha = 1
            }
        }
    }

    @IBAction func goToUserPage(_ sender: Any) {
        if let userProfilePage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: ProfileVC.reuseIdentifier) as? ProfileVC {
            userProfilePage.otherUserID = otherUserID
            controller?.navigationController?.pushViewController(userProfilePage, animated: true)
        }
    }
}
