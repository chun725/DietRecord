//
//  AddFriendVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import UIKit

class AddFollowingVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    let profileProvider = ProfileProvider()
    var userSearchResult: User? {
        didSet {
            userImageView.loadImage(userSearchResult?.userImageURL)
            usernameLabel.text = userSearchResult?.username
            if userSearchResult?.followers.contains(userID) != false {
                followButton.setTitle("Following", for: .normal)
            } else if userSearchResult?.request.contains(userID) != false {
                followButton.setTitle("Requested", for: .normal)
                followButton.backgroundColor = .drGray
            } else {
                followButton.setTitle("Follow", for: .normal)
            }
            usernameLabel.isHidden = false
            userImageView.isHidden = false
            followButton.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInputTextField.delegate = self
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        followButton.addTarget(self, action: #selector(requestFollow), for: .touchUpInside)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let userInput = userInputTextField.text else { return }
        if !userInput.isEmpty {
            profileProvider.fetchUserData(userID: userInput) { result in
                switch result {
                case .success(let user):
                    self.userSearchResult = user
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else {
            let alert = UIAlertController(title: "請輸入用戶名稱", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: false)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
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
            self.present(alert, animated: false)
        }
    }
}
