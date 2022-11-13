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
    @IBOutlet weak var timeLabel: UILabel!
    
    weak var controller: UIViewController?
    let profileProvider = ProfileProvider()
    var haveResponses = true
    var mealRecord: MealRecord?
    var otherUserID: String?
    
    func layoutCell(mealRecord: MealRecord) {
        self.backgroundColor = .clear
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        profileProvider.fetchUserData(userID: mealRecord.userID) { result in
            switch result {
            case .success(let user):
                self.usernameLabel.text = user.username
                self.userImageView.loadImage(user.userImageURL)
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
        mealImageView.loadImage(mealRecord.imageURL)
        mealCommentLabel.text = mealRecord.comment
        likedCountLabel.text = "\(mealRecord.peopleLiked.count)人說讚"
        likeButton.addTarget(self, action: #selector(addLiked), for: .touchUpInside)
        checkResponseButton.addTarget(self, action: #selector(goToProfileDetailPage), for: .touchUpInside)
        self.mealRecord = mealRecord
        otherUserID = mealRecord.userID
        if haveResponses {
            checkResponseButton.isHidden = true
            timeLabel.isHidden = false
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
            responseButton.addTarget(self, action: #selector(goToProfileDetailPage), for: .touchUpInside)
        }
        if mealRecord.peopleLiked.contains(userID) {
            likeButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tag = mealRecord.peopleLiked.count - 1
        } else {
            likeButton.tag = mealRecord.peopleLiked.count
        }
    }
    
    @objc func addLiked(sender: UIButton) {
        if sender.backgroundImage(for: .normal) == UIImage(systemName: "heart") {
            sender.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            likedCountLabel.text = "\(sender.tag + 1)人說讚"
        } else {
            sender.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            likedCountLabel.text = "\(sender.tag)人說讚"
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
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let profileDetailPage = storyboard.instantiateViewController(withIdentifier: "\(ProfileDetailVC.self)")
            as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            controller?.navigationController?.pushViewController(profileDetailPage, animated: false)
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
    
    @objc func beginResponse() {
        if let controller = controller as? ProfileDetailVC {
            controller.responseTextView.becomeFirstResponder()
        }
    }
}
