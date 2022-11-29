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
    
    let profileProvider = ProfileProvider()
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
        self.tabBarController?.tabBar.isHidden = true
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let userInput = userInputTextField.text,
            let userData = DRConstant.userData
        else { return }
        if !userInput.isEmpty {
            DRProgressHUD.show()
            profileProvider.searchUser(userSelfID: userInput) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if response as? String == "document不存在" {
                        DRProgressHUD.showFailure(text: "無此用戶")
                        self.hiddenView(views: [self.usernameLabel, self.userImageView, self.followButton])
                        self.animationView.isHidden = false
                    } else {
                        guard let user = response as? User else { return }
                        if userData.blocks.contains(user.userID) {
                            DRProgressHUD.showFailure(text: "無此用戶")
                            self.animationView.isHidden = false
                        } else {
                            DRProgressHUD.dismiss()
                            self.userSearchResult = user
                            self.animationView.isHidden = true
                        }
                    }
                case .failure(let error):
                    DRProgressHUD.showFailure(text: "無法查詢用戶")
                    print("Error Info: \(error).")
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func requestFollow(sender: UIButton) {
        guard let userSearchResult = userSearchResult else { return }
        if sender.title(for: .normal) == "Follow" {
            profileProvider.changeRequest(isRequest: false, followID: userSearchResult.userID) { result in
                switch result {
                case .success:
                    sender.setTitle("Requested", for: .normal)
                    sender.backgroundColor = .drGray
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else if sender.title(for: .normal) == "Requested" {
            profileProvider.changeRequest(isRequest: true, followID: userSearchResult.userID) { result in
                switch result {
                case .success:
                    sender.setTitle("Follow", for: .normal)
                    sender.backgroundColor = .drDarkGray
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else {
            let alert = UIAlertController(
                title: "確定要取消對\(userSearchResult.username)的追蹤?",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { _ in
                self.profileProvider.changeFollow(isFollowing: true, followID: userSearchResult.userID) { result in
                    switch result {
                    case .success:
                        sender.setTitle("Follow", for: .normal)
                    case .failure(let error):
                        print("Error Info: \(error).")
                    }
                }
            }
            let cancel = UIAlertAction(title: "返回", style: .default)
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
