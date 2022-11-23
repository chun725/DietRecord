//
//  SettingInfoCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit
import FirebaseAuth
import SafariServices

class ProfileSettingCell: UITableViewCell, SFSafariViewControllerDelegate {
    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var weightGoalLabel: UILabel!
    @IBOutlet weak var dietGoalLabel: UILabel!
    
    weak var controller: ProfileSettingVC?
    let profileProvider = ProfileProvider()
    
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
    
    @IBAction func goToPrivacyPolicy(_ sender: Any) {
        if let url = URL(string: "https://www.privacypolicies.com/live/0c52d156-f8ce-45f0-a5b0-74476275c555") {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = .drDarkGray
            safari.dismissButtonStyle = .close
            safari.delegate = self
            controller?.navigationController?.pushViewController(safari, animated: false)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.navigationController?.popViewController(animated: false)
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
        let alert = UIAlertController(title: "確定要刪除帳號？", message: "這會刪除所有您App裡的相關資料及記錄", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "確定", style: .destructive) { [weak self] _ in
            LKProgressHUD.show()
            let firebaseAuth = Auth.auth()
            guard let nowUserData = userData else { return }
            let allUsers = nowUserData.followers + nowUserData.following
            self?.profileProvider.removeFollow(allUsers: allUsers) { [weak self] result in
                switch result {
                case .success:
                    do {
                        firebaseAuth.currentUser?.delete()
                        try firebaseAuth.signOut()
                        self?.profileProvider.deleteAccount { result in
                            switch result {
                            case .success:
                                userID = ""
                                userData = nil
                                LKProgressHUD.dismiss()
                                self?.controller?
                                    .tabBarController?
                                    .navigationController?
                                    .popToRootViewController(animated: false)
                                print("刪除帳號")
                            case .failure(let error):
                                print("Error Info: \(error) in deleting account.")
                            }
                        }
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                case .failure(let error):
                    print("Error Info: \(error) in deleting account.")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        controller?.present(alert, animated: false)
    }
}
