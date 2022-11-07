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
    
    let profileProvider = ProfileProvider()
    var meal = 0
    var date = ""
    var haveResponses = true
    
    func layoutCell(username: String, userImage: String, mealRecord: MealRecord) {
        self.backgroundColor = .clear
        usernameLabel.text = username
        userImageView.loadImage(userImage)
        mealImageView.loadImage(mealRecord.imageURL)
        mealCommentLabel.text = mealRecord.comment
        likedCountLabel.text = "\(mealRecord.peopleLiked.count)人說讚"
        likeButton.addTarget(self, action: #selector(addLiked), for: .touchUpInside)
        self.meal = mealRecord.meal
        self.date = mealRecord.date
        if haveResponses {
            checkResponseButton.isHidden = true
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
        profileProvider.changeLiked(userID: userID, date: date, meal: meal) { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
}
