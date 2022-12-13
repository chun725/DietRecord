//
//  ProfileVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ProfileVC: UIViewController {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var followStackView: UIStackView!
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTitleLabel: UILabel!
    var otherUserID: String?
    var otherUserData: User?
    var mealRecords: [MealRecord] = [] {
        didSet {
            photoCollectionView.reloadData()
            postLabel.text = String(mealRecords.count)
        }
    }
    
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
        }
        moreButton.isEnabled = otherUserID == DRConstant.userID ? false : true
        moreButton.tintColor = otherUserID == DRConstant.userID ? .drGray : .drDarkGray
        editButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDietRecord()
        fetchData()
        if otherUserID == nil {
            self.navigationController?.navigationBar.isHidden = true
            titleLabelHeightConstraint.constant = self.navigationController?.navigationBar.frame.height ?? 0.0
        } else {
            self.navigationController?.navigationBar.isHidden = false
            titleLabelHeightConstraint.constant = 0
        }
        editButton.addTarget(self, action: #selector(requestFollow), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if otherUserID == nil {
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func fetchDietRecord() {
        DRProgressHUD.show()
        var id = DRConstant.userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        FirebaseManager.shared.fetchImage(userID: id) { [weak self] dietRecords in
            guard let self = self else { return }
            DRProgressHUD.dismiss()
            var mealDatas: [MealRecord] = []
            for dietRecord in dietRecords {
                let mealRecords = dietRecord.mealRecord.sorted { $0.meal < $1.meal }.filter { $0.isShared }
                mealDatas.append(contentsOf: mealRecords)
            }
            self.mealRecords = mealDatas.reversed()
        }
    }
    
    func fetchData() {
        DRProgressHUD.show()
        var id = DRConstant.userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        FirebaseManager.shared.fetchUserData(userID: id) { [weak self] userData in
            DRProgressHUD.dismiss()
            guard let self = self,
                let userData = userData
            else { return }
            
            self.followersLabel.text = String(userData.followers.count)
            self.followingLabel.text = String(userData.following.count)
            self.usernameLabel.text = userData.username
            self.userImageView.loadImage(userData.userImageURL)
            self.titleLabel.text = userData.userSelfID
            self.navigationBarTitleLabel.text = userData.userSelfID
            self.presentView(views: [self.userImageView, self.followStackView, self.editButton])
            
            if id == DRConstant.userID {
                DRConstant.userData = userData
            } else {
                self.otherUserData = userData
            }
            
            if userData.userID == DRConstant.userID {
                self.photoCollectionView.isHidden = false
                self.editButton.setTitle("查看個人資料", for: .normal)
            } else if userData.followers.contains(DRConstant.userID) {
                self.photoCollectionView.isHidden = false
                self.editButton.setTitle("Following", for: .normal)
            } else if userData.request.contains(DRConstant.userID) {
                self.editButton.setTitle("Requested", for: .normal)
                self.editButton.backgroundColor = .drGray
                self.followersButton.isEnabled = false
                self.followingButton.isEnabled = false
            } else {
                self.editButton.setTitle("Follow", for: .normal)
                self.followersButton.isEnabled = false
                self.followingButton.isEnabled = false
            }
        }
    }
    
    @IBAction func goToCheckRequestPage(_ sender: UIButton) {
        if let checkRequestPage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: CheckRequestVC.reuseIdentifier) as? CheckRequestVC {
            var id = DRConstant.userID
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
            self.navigationController?.pushViewController(checkRequestPage, animated: true)
        }
    }
    
    @IBAction func goToAddFollowingPage(_ sender: Any) {
        if let addFollowingPage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: AddFollowingVC.reuseIdentifier) as? AddFollowingVC {
            self.navigationController?.pushViewController(addFollowingPage, animated: true)
        }
    }
    
    @IBAction func goToHomePage(_ sender: Any) {
        if let homePage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: ProfileHomePageVC.reuseIdentifier) as? ProfileHomePageVC {
            self.navigationController?.pushViewController(homePage, animated: true)
        }
    }
    
    @IBAction func reportOrBlock(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "檢舉用戶", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            FirebaseManager.shared.reportSomething(
                user: self.otherUserData,
                mealRecord: nil,
                response: nil) {
                print("成功檢舉")
            }
        }
        let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive) { [weak self] _ in
            guard let self = self,
                let otherUserID = self.otherUserID
            else { return }
            FirebaseManager.shared.changeBlock(blockID: otherUserID) {
                self.navigationController?.popViewController(animated: true)
                print("成功封鎖")
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(blockAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true)
    }
    
    @objc func requestFollow(sender: UIButton) {
        guard let otherUserID = otherUserID,
            let otherUserData = otherUserData
        else {
            if let profileSettingPage = UIStoryboard.profile.instantiateViewController(
                withIdentifier: ProfileSettingVC.reuseIdentifier)
                as? ProfileSettingVC {
                self.navigationController?.pushViewController(profileSettingPage, animated: true)
            }
            return }
        if sender.title(for: .normal) == "Follow" {
            FirebaseManager.shared.changeRequest(isRequest: false, followID: otherUserID) {
                sender.setTitle("Requested", for: .normal)
                sender.backgroundColor = .drGray
            }
        } else if sender.title(for: .normal) == "Requested" {
            FirebaseManager.shared.changeRequest(isRequest: true, followID: otherUserID) {
                sender.setTitle("Follow", for: .normal)
                sender.backgroundColor = .drDarkGray
            }
        } else {
            let alert = UIAlertController(
                title: "確定要移除對\(otherUserData.username)的追蹤?",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { _ in
                FirebaseManager.shared.changeFollow(isFollowing: true, followID: otherUserID) {
                    sender.setTitle("Follow", for: .normal)
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
}


extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        if let profileDetailPage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: ProfileDetailVC.reuseIdentifier) as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            if let otherUserData = otherUserData {
                profileDetailPage.nowUserData = otherUserData
            } else {
                profileDetailPage.nowUserData = DRConstant.userData
            }
            self.navigationController?.pushViewController(profileDetailPage, animated: true)
        }
    }
    
    // MARK: - DelegateFlowLayout -
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (DRConstant.fullScreenSize.width - 10) / 3
        let size = CGSize(width: width, height: width)
        return size
    }
    
    // MARK: - FlowLayout -
    func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
}
