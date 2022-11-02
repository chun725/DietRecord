//
//  KingFisherWrapper.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {
        guard let urlString = urlString,
            let url = URL(string: urlString)
        else { return }
        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
