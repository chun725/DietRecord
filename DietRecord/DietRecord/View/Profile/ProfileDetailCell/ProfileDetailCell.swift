//
//  ProfileDetailCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import UIKit

class ProfileDetailCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealCommentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var responseButton: UIButton!
    @IBOutlet weak var likedCountLabel: UILabel!
    @IBOutlet weak var checkResponseButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var foodCollectionView: UICollectionView! {
        didSet {
            foodCollectionView.dataSource = self
            foodCollectionView.delegate = self
            foodCollectionView.collectionViewLayout = configureLayout()
            foodCollectionView.registerCellWithNib(identifier: FoodCollectionViewCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var responseCountLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeBackground: UIView!
    
    weak var controller: UIViewController?
    let profileProvider = ProfileProvider()
    var haveResponses = true
    var mealRecord: MealRecord? {
        didSet {
            foodCollectionView.reloadData()
        }
    }
    var otherUserID: String?
    
    func layoutCell(mealRecord: MealRecord, nowUserData: User?) {
        configureUserData(mealRecord: mealRecord, nowUserData: nowUserData)
        self.backgroundColor = .clear
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        likeBackground.layer.cornerRadius = 10
        mealImageView.loadImage(mealRecord.imageURL)
        mealCommentLabel.text = mealRecord.comment
        likedCountLabel.text = "\(mealRecord.peopleLiked.count)"
        guard let userData = DRConstant.userData else { return }
        let responses = mealRecord.response.filter { !(userData.blocks.contains($0.person)) }
        responseCountLabel.text = "\(responses.count)"
        likeButton.addTarget(self, action: #selector(addLiked), for: .touchUpInside)
        checkResponseButton.addTarget(self, action: #selector(goToProfileDetailPage), for: .touchUpInside)
        self.mealRecord = mealRecord
        otherUserID = mealRecord.userID
        if haveResponses {
            checkResponseButton.isHidden = true
            var mealString = ""
            switch mealRecord.meal {
            case 0:
                mealString = Meal.breakfast.rawValue
            case 1:
                mealString = Meal.lunch.rawValue
            case 2:
                mealString = Meal.dinner.rawValue
            default:
                mealString = Meal.others.rawValue
            }
            timeLabel.text = mealRecord.date + " " + mealString
            responseButton.addTarget(self, action: #selector(beginResponse), for: .touchUpInside)
        } else {
            timeLabel.text = DRConstant.dateFormatter.string(from: mealRecord.createdTime)
            responseButton.addTarget(self, action: #selector(goToProfileDetailPage), for: .touchUpInside)
        }
        if mealRecord.peopleLiked.contains(DRConstant.userID) {
            likeButton.setBackgroundImage(
                UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate),
                for: .normal)
            likeButton.tintColor = .red
            likeButton.tag = mealRecord.peopleLiked.count - 1
        } else {
            likeButton.setBackgroundImage(
                UIImage(systemName: "heart"),
                for: .normal)
            likeButton.tintColor = .white
            likeButton.tag = mealRecord.peopleLiked.count
        }
        if mealRecord.comment.isEmpty {
            timeLabelTopConstraint.constant = 0
        }
    }
    
    private func configureUserData(mealRecord: MealRecord, nowUserData: User?) {
        if let nowUserData = nowUserData {
            usernameLabel.text = nowUserData.username
            userImageView.loadImage(nowUserData.userImageURL)
            if let controller = controller as? ProfileDetailVC {
                controller.userSelfIDLabel.text = nowUserData.userSelfID
            }
        } else {
            profileProvider.fetchUserData(userID: mealRecord.userID) { result in
                switch result {
                case .success(let user):
                    guard let user = user as? User else { return }
                    self.usernameLabel.text = user.username
                    self.userImageView.loadImage(user.userImageURL)
                    if let controller = self.controller as? ProfileDetailVC {
                        controller.userSelfIDLabel.text = user.userSelfID
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        }
        moreButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if mealRecord.userID == DRConstant.userID {
            moreButton.addTarget(self, action: #selector(deletePost), for: .touchUpInside)
        } else {
            moreButton.addTarget(self, action: #selector(reportOrBlock), for: .touchUpInside)
        }
    }
    
    @objc func reportOrBlock() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "檢舉貼文", style: .destructive) { [weak self] _ in
            self?.profileProvider.reportSomething(
                user: nil,
                mealRecord: self?.mealRecord,
                response: nil) { result in
                switch result {
                case .success:
                    print("success report")
                case .failure(let error):
                    print("Error Info: \(error) in reporting something.")
                }
            }
        }
        let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive) { [weak self] _ in
            guard let mealRecord = self?.mealRecord else { return }
            self?.profileProvider.changeBlock(blockID: mealRecord.userID) { result in
                switch result {
                case .success:
                    print("成功封鎖用戶")
                    if let controller = self?.controller as? ProfileDetailVC {
                        controller.navigationController?.popViewController(animated: true)
                    } else if let controller = self?.controller as? ProfileHomePageVC {
                        controller.fetchFollowingPost()
                    }
                case .failure(let error):
                    print("Error Info: \(error) in blocking user.")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(blockAction)
        optionMenu.addAction(cancelAction)
        controller?.present(optionMenu, animated: true)
    }
    
    @objc func deletePost() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "刪除貼文", style: .destructive) { [weak self] _ in
            guard let mealRecord = self?.mealRecord else { return }
            self?.profileProvider.deletePostOrResponse(mealRecord: mealRecord, response: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    print("成功刪除貼文")
                    if self.haveResponses {
                        if let controller = self.controller as? ProfileDetailVC {
                            controller.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        if let controller = self.controller as? ProfileHomePageVC {
                            controller.fetchFollowingPost()
                        }
                    }
                case .failure(let error):
                    print("Error Info: \(error) in deleting post.")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        controller?.present(optionMenu, animated: true)
    }
    
    @objc func addLiked(sender: UIButton) {
        if sender.backgroundImage(for: .normal) == UIImage(systemName: "heart") {
            sender.setBackgroundImage(
                UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate),
                for: .normal)
            sender.tintColor = .red
            likedCountLabel.text = "\(sender.tag + 1)"
        } else {
            sender.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            sender.tintColor = .white
            likedCountLabel.text = "\(sender.tag)"
        }
        guard let mealRecord = mealRecord else { return }
        profileProvider.changeLiked(
            authorID: mealRecord.userID,
            date: mealRecord.date,
            meal: mealRecord.meal) { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @objc func goToProfileDetailPage() {
        let storyboard = UIStoryboard(name: DRConstant.profile, bundle: nil)
        if let profileDetailPage = storyboard.instantiateViewController(withIdentifier: "\(ProfileDetailVC.self)")
            as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            controller?.navigationController?.pushViewController(profileDetailPage, animated: true)
        }
    }
    
    @IBAction func goToUserPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.profile, bundle: nil)
        if let userProfilePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileVC.self)")
            as? ProfileVC {
            userProfilePage.otherUserID = otherUserID
            controller?.navigationController?.pushViewController(userProfilePage, animated: true)
        }
    }
    
    @objc func beginResponse() {
        if let controller = controller as? ProfileDetailVC {
            controller.responseTextField.becomeFirstResponder()
        }
    }
}

extension ProfileDetailCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mealRecord?.foods.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FoodCollectionViewCell.reuseIdentifier, for: indexPath) as? FoodCollectionViewCell,
            let mealRecord = mealRecord
        else { fatalError("Could not create the food collection cell.") }
        let food = mealRecord.foods[indexPath.row]
        cell.layoutCell(foodname: food.foodIngredient.name)
        return cell
    }
    
    func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: DRConstant.dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            guard let food = mealRecord?.foods[indexPath.row] else { return }
            foodNutritionPage.food = food.foodIngredient
            foodNutritionPage.isCollectionCell = true
            controller?.navigationController?.pushViewController(foodNutritionPage, animated: true)
        }
    }
}
