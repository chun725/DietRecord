//
//  AddFriendVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import UIKit
import Lottie

class AddFollowingVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    var userSearchResult: User? {
        didSet {
            userImageView.loadImage(userSearchResult?.userImageURL)
            usernameLabel.text = userSearchResult?.username
            if userSearchResult?.followers.contains(DRConstant.userID) != false {
                followButton.setTitle("Following", for: .normal)
                followButton.backgroundColor = .drDarkGray
            } else if userSearchResult?.request.contains(DRConstant.userID) != false {
                followButton.setTitle("Requested", for: .normal)
                followButton.backgroundColor = .drGray
            } else {
                followButton.setTitle("Follow", for: .normal)
                followButton.backgroundColor = .drDarkGray
            }
            self.presentView(views: [usernameLabel, userImageView, followButton])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInputTextField.delegate = self
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        followButton.addTarget(self, action: #selector(requestFollow), for: .touchUpInside)
        followButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        animationView.loopMode = .loop
        animationView.play()
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
                    self.animationView.isHidden = false
                }
            }
        }
    }
    
    @objc func requestFollow(sender: UIButton) {
        guard let userSearchResult = userSearchResult else { return }
        if sender.title(for: .normal) == "Follow" {
            FirebaseManager.shared.changeRequest(isRequest: false, followID: userSearchResult.userID) {
                sender.setTitle("Requested", for: .normal)
                sender.backgroundColor = .drGray
            }
        } else if sender.title(for: .normal) == "Requested" {
            FirebaseManager.shared.changeRequest(isRequest: true, followID: userSearchResult.userID) {
                sender.setTitle("Follow", for: .normal)
                sender.backgroundColor = .drDarkGray
            }
        } else {
            let alert = UIAlertController(
                title: "確定要移除對\(userSearchResult.username)的追蹤?",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { _ in
                FirebaseManager.shared.changeFollow(isFollowing: true, followID: userSearchResult.userID) {
                    sender.setTitle("Follow", for: .normal)
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func goToUserPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.profile, bundle: nil)
        if let userProfilePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileVC.self)")
            as? ProfileVC {
            userProfilePage.otherUserID = self.userSearchResult?.userID
            self.navigationController?.pushViewController(userProfilePage, animated: true)
        }
    }
}
