//
//  AddFriendVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import UIKit
import Lottie

class AddFollowingVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userInputTextField: UITextField! {
        didSet {
            userInputTextField.delegate = self
        }
    }
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        }
    }
    @IBOutlet weak var cannotFollowSelfLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.addTarget(self, action: #selector(requestFollow), for: .touchUpInside)
            followButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var animationView: LottieAnimationView! {
        didSet {
            animationView.loopMode = .loop
            animationView.play()
        }
    }
    
    var userSearchResult: User? {
        didSet {
            userImageView.loadImage(userSearchResult?.userImageURL)
            usernameLabel.text = userSearchResult?.username
            if userSearchResult?.followers.contains(DRConstant.userID) != false {
                followButton.setTitle(FollowString.following.rawValue, for: .normal)
                followButton.backgroundColor = .drDarkGray
            } else if userSearchResult?.request.contains(DRConstant.userID) != false {
                followButton.setTitle(FollowString.requested.rawValue, for: .normal)
                followButton.backgroundColor = .drGray
            } else {
                followButton.setTitle(FollowString.follow.rawValue, for: .normal)
                followButton.backgroundColor = .drDarkGray
            }
            
            self.presentView(views: [usernameLabel, userImageView])
            followButton.isHidden = userSearchResult?.userID == DRConstant.userID
            cannotFollowSelfLabel.isHidden = userSearchResult?.userID != DRConstant.userID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        if userSearchResult != nil {
            textFieldDidEndEditing(userInputTextField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let userInput = userInputTextField.text,
            let myUserData = DRConstant.userData
        else { return }
        if !userInput.isEmpty {
            DRProgressHUD.show()
            FirebaseManager.shared.searchUser(userSelfID: userInput) { [weak self] userData in
                guard let self = self else { return }
                if let userData = userData, !myUserData.blocks.contains(userData.userID) {
                    DRProgressHUD.dismiss()
                    self.userSearchResult = userData
                    self.animationView.isHidden = true
                } else {
                    DRProgressHUD.showFailure(text: "無此用戶")
                    self.hiddenView(views: [self.usernameLabel, self.userImageView, self.followButton])
                    self.animationView.play()
                    self.animationView.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Action -
    @objc func requestFollow(sender: UIButton) {
        guard let userSearchResult = userSearchResult else { return }
        if sender.title(for: .normal) == FollowString.follow.rawValue {
            FirebaseManager.shared.changeRequest(isRequest: false, followID: userSearchResult.userID) {
                sender.setTitle(FollowString.requested.rawValue, for: .normal)
                sender.backgroundColor = .drGray
            }
        } else if sender.title(for: .normal) == FollowString.requested.rawValue {
            FirebaseManager.shared.changeRequest(isRequest: true, followID: userSearchResult.userID) {
                sender.setTitle(FollowString.follow.rawValue, for: .normal)
                sender.backgroundColor = .drDarkGray
            }
        } else {
            let alert = UIAlertController(
                title: "確定要移除對\(userSearchResult.username)的追蹤?",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { _ in
                FirebaseManager.shared.changeFollow(isFollowing: true, followID: userSearchResult.userID) {
                    sender.setTitle(FollowString.follow.rawValue, for: .normal)
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func goToUserPage(_ sender: Any) {
        if let userProfilePage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: ProfileVC.reuseIdentifier) as? ProfileVC {
            userProfilePage.otherUserID = self.userSearchResult?.userID
            self.navigationController?.pushViewController(userProfilePage, animated: true)
        }
    }
}
