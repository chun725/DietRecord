//
//  RequestCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/8.
//

import UIKit

class RequestCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var controller: CheckRequestVC?
    var user: User?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkButton.isEnabled = true
        cancelButton.isEnabled = true
    }
    
    func layoutCell(user: User) {
        self.backgroundColor = .clear
        usernameLabel.text = user.username
        userImageView.loadImage(user.userImageURL)
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        self.user = user
    }
    
    @IBAction func checkRequest(_ sender: Any) {
        checkButton.isEnabled = false
        cancelButton.isEnabled = false
        guard let user = user else { return }
        FirebaseManager.shared.changeFollow(isFollowing: false, followID: user.userID) { [weak self] in
            guard let self = self else { return }
            self.controller?.fetchRequest()
        }
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        checkButton.isEnabled = false
        cancelButton.isEnabled = false
        guard let user = user else { return }
        FirebaseManager.shared.cancelRequest(followID: user.userID) { [weak self] in
            guard let self = self else { return }
            self.controller?.fetchRequest()
        }
    }
}
