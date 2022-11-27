//
//  UITableViewCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    func superTableView() -> UITableView? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        return  nil
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

extension UITableView {
    func registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }
}
