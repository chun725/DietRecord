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
            case .success(let user):
                guard let user = user as? User else { return }
                self.usernameLabel.text = user.username
                self.userImageView.loadImage(user.userImageURL)
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }

    @IBAction func goToUserPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let userProfilePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileVC.self)")
            as? ProfileVC {
            userProfilePage.otherUserID = otherUserID
            controller?.navigationController?.pushViewController(userProfilePage, animated: false)
        }
    }
}
