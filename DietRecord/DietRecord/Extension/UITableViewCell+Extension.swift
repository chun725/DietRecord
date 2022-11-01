//
//  UITableViewCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit

extension UITableViewCell {
    func superTableView() -> UITableView? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        return  nil
    }
}
