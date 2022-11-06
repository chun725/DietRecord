//
//  UICollectionView+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
