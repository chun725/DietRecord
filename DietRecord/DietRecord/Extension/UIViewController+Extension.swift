//
//  UIViewController+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

extension UIViewController {
    func presentInputAlert() {
        let alert = UIAlertController(title: "輸入欄不得為空", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: false)
    }
}
