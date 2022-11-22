//
//  SettingInfoCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit
import FirebaseAuth

class ProfileSettingCell: UITableViewCell {
    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var weightGoalLabel: UILabel!
    @IBOutlet weak var dietGoalLabel: UILabel!
    
    weak var controller: ProfileSettingVC?
    
    func layoutCell() {
        guard let userData = userData else { return }
        usernameLabel.text = userData.username
        waterGoalLabel.text = userData.waterGoal.transform(unit: mLUnit)
        weightGoalLabel.text = userData.weightGoal.transform(unit: kgUnit)
        dietGoalLabel.text = userData.goal[0].transform(unit: kcalUnit)
        userImageView.loadImage(userData.userImageURL)
        userImageView.layer.cornerRadius = 50
        infoBackgroundView.setShadowAndRadius(radius: 15)
    }
    
    @IBAction func editInfo(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let profileInfoPage = storyboard.instantiateViewController(
            withIdentifier: "\(ProfileInformationVC.self)")
            as? ProfileInformationVC {
            profileInfoPage.isUpdated = true
            controller?.navigationController?.pushViewController(profileInfoPage, animated: false)
        }
    }
    
    @IBAction func blockUsers(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let blockUsersPage = storyboard.instantiateViewController(withIdentifier: "\(CheckRequestVC.self)")
            as? CheckRequestVC {
            blockUsersPage.need = "BlockUsers"
            controller?.navigationController?.pushViewController(blockUsersPage, animated: false)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            userID = ""
            userData = nil
            controller?.tabBarController?.navigationController?.popToRootViewController(animated: false)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
    }
}
