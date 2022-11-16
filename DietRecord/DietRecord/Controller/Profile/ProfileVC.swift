//
//  ProfileVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    
    var otherUserID: String?
    var otherUserData: User?
    var mealRecords: [MealRecord] = [] {
        didSet {
            photoCollectionView.reloadData()
            postLabel.text = String(mealRecords.count)
        }
    }
    
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.collectionViewLayout = configureLayout()
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        if otherUserID != nil {
            self.homeButton.isHidden = true
            self.checkButton.isHidden = true
            self.addButton.isHidden = true
            self.photoCollectionView.isHidden = true
            titleLabel.text = ""
        } else {
            self.backButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mealRecords.isEmpty {
            fetchDietRecord()
            fetchData()
        }
        if otherUserID == nil {
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.tabBarController?.tabBar.isHidden = true
        }
        editButton.addTarget(self, action: #selector(requestFollow), for: .touchUpInside)
    }
    
    func fetchDietRecord() {
        LKProgressHUD.show()
        var id = userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        profileProvider.fetchImage(userID: id) { result in
            switch result {
            case .success(let dietRecords):
                LKProgressHUD.dismiss()
                var mealDatas: [MealRecord] = []
                for dietRecord in dietRecords {
                    let mealRecords = dietRecord.mealRecord.sorted { $0.meal < $1.meal }.filter { $0.isShared }
                    mealDatas.append(contentsOf: mealRecords)
                }
                self.mealRecords = mealDatas.reversed()
            case .failure(let error):
                LKProgressHUD.showFailure(text: "無法讀取用戶資料")
                print("Error Info: \(error).")
            }
        }
    }
    
    func fetchData() {
        LKProgressHUD.show()
        var id = userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        profileProvider.fetchUserData(userID: id) { result in
            switch result {
            case .success(let user):
                LKProgressHUD.dismiss()
                guard let user = user as? User else { return }
                self.followersLabel.text = String(user.followers.count)
                self.followingLabel.text = String(user.following.count)
                self.usernameLabel.text = user.username
                self.userImageView.loadImage(user.userImageURL)
                if id == userID {
                    userData = user
                } else {
                    self.otherUserData = user
                }
                if user.userID == userID {
                    self.photoCollectionView.isHidden = false
                    self.editButton.setTitle("編輯個人資料", for: .normal)
                } else if user.followers.contains(userID) {
                    self.photoCollectionView.isHidden = false
                    self.editButton.setTitle("Following", for: .normal)
                } else if user.request.contains(userID) {
                    self.editButton.setTitle("Requested", for: .normal)
                    self.editButton.backgroundColor = .drGray
                    self.followersButton.isEnabled = false
                    self.followingButton.isEnabled = false
                } else {
                    self.editButton.setTitle("Follow", for: .normal)
                    self.followersButton.isEnabled = false
                    self.followingButton.isEnabled = false
                }
            case .failure(let error):
                LKProgressHUD.showFailure(text: "無法讀取用戶資料")
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goToCheckRequestPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let checkRequestPage = storyboard.instantiateViewController(withIdentifier: "\(CheckRequestVC.self)")
            as? CheckRequestVC {
            var id = userID
            if let otherUserID = otherUserID {
                id = otherUserID
            }
            if sender == followingButton {
                checkRequestPage.need = "Following"
                checkRequestPage.otherUserID = id
            } else if sender == followersButton {
                checkRequestPage.need = "Followers"
                checkRequestPage.otherUserID = id
            }
            self.navigationController?.pushViewController(checkRequestPage, animated: false)
        }
    }
    
    @IBAction func goToAddFollowingPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let addFollowingPage = storyboard.instantiateViewController(withIdentifier: "\(AddFollowingVC.self)")
            as? AddFollowingVC {
            self.navigationController?.pushViewController(addFollowingPage, animated: false)
        }
    }
    
    @IBAction func goToHomePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let homePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileHomePageVC.self)")
            as? ProfileHomePageVC {
            self.navigationController?.pushViewController(homePage, animated: false)
        }
    }
    
    @objc func requestFollow(sender: UIButton) {
        guard let otherUserID = otherUserID, let otherUserData = otherUserData else { return }
        if sender.title(for: .normal) == "Follow" {
            profileProvider.changeRequest(isRequest: false, followID: otherUserID) { result in
                switch result {
                case .success:
                    sender.setTitle("Requested", for: .normal)
                    sender.backgroundColor = .drGray
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else if sender.title(for: .normal) == "Requested" {
            profileProvider.changeRequest(isRequest: true, followID: otherUserID) { result in
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
                title: "確定要取消對\(otherUserData.username)的追蹤?",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { _ in
                self.profileProvider.changeFollow(isFollowing: true, followID: otherUserID) { result in
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
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - CollectionViewDataSource -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mealRecords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCell.reuseIdentifier, for: indexPath) as? ProfileCell
        else { fatalError("Could not create the profile cell.") }
        let mealRecord = mealRecords[indexPath.row]
        cell.layoutCell(imageURL: mealRecord.imageURL)
        return cell
    }
    
    // MARK: - CollectionViewDelegate -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mealRecord = mealRecords[indexPath.row]
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let profileDetailPage = storyboard.instantiateViewController(withIdentifier: "\(ProfileDetailVC.self)")
            as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            self.navigationController?.pushViewController(profileDetailPage, animated: false)
        }
    }
}


extension ProfileVC: UICollectionViewDelegateFlowLayout {
    // MARK: - DelegateFlowLayout -
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: CGFloat(fullScreenSize.width / 3), height: CGFloat(fullScreenSize.width) / 3)
        return size
    }
    
    // MARK: - FlowLayout -
    func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
}
