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
    let profileProvider = ProfileProvider()
    
    func layoutCell(response: Response) {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        self.backgroundColor = .clear
        responseLabel.text = response.response
        self.otherUserID = response.person
        profileProvider.fetchUserData(userID: response.person) { result in
            switch result {
            case .success(let result):
                if result as? String == "document不存在" {
                    self.usernameLabel.text = "Unknown"
                    self.goToUserPageButton.isEnabled = false
                } else if let user = result as? User {
                    self.goToUserPageButton.isEnabled = true
                    self.usernameLabel.text = user.username
                    self.userImageView.loadImage(user.userImageURL)
                }
                UIView.animate(withDuration: 0.5) {
                    self.usernameLabel.alpha = 1
                    self.userImageView.alpha = 1
                    self.responseLabel.alpha = 1
                }
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }

    @IBAction func goToUserPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.profile, bundle: nil)
        if let userProfilePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileVC.self)")
            as? ProfileVC {
            userProfilePage.otherUserID = otherUserID
            controller?.navigationController?.pushViewController(userProfilePage, animated: false)
        }
    }
}
