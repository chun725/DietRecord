//
//  UIViewController+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

extension UIViewController {
    func presentInputAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: false)
    }
    
    func presentView(views: [UIView]) {
        for view in views {
            view.isHidden = false
        }
    }
    
    func hiddenView(views: [UIView]) {
        for view in views {
            view.isHidden = true
        }
    }
}
