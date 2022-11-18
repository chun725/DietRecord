//
//  ProfileCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!

    func layoutCell(imageURL: String?) {
        photoImageView.loadImage(imageURL)
        photoImageView.layer.cornerRadius = 10
    }
}
