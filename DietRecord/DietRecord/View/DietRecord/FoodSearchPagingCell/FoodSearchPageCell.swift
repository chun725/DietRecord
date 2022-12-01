//
//  FoodSearchFooterView.swift
//  DietRecord
//
//  Created by chun on 2022/12/1.
//

import UIKit

class FoodSearchPagingCell: UITableViewCell {
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var lastPageButton: UIButton!
    
    weak var controller: FoodSearchVC?
    
    func layoutCell() {
        guard let controller = controller else { return }
        if controller.nowPage == 0 {
            lastPageButton.isEnabled = false
            lastPageButton.setTitleColor(.drGray, for: .normal)
        } else {
            lastPageButton.isEnabled = true
            lastPageButton.setTitleColor(.drDarkGray, for: .normal)
        }
        if controller.nowPage == controller.pages ||
            (controller.nowPage + 1 == controller.pages && controller.lastPageCount == 0) {
            nextPageButton.isEnabled = false
            nextPageButton.setTitleColor(.drGray, for: .normal)
        } else {
            nextPageButton.isEnabled = true
            nextPageButton.setTitleColor(.drDarkGray, for: .normal)
        }
    }
    
    @IBAction func changePage(_ sender: UIButton) {
        guard let controller = controller else { return }
        if sender == nextPageButton {
            controller.nowPage += 1
        } else {
            controller.nowPage -= 1
        }
        controller.progressView.alpha = 1
        controller.indicatorView.alpha = 1
        controller.searchResultTableView.reloadData()
        controller.searchResultTableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: false)
        UIView.animate(withDuration: 1) {
            controller.indicatorView.alpha = 0
            controller.progressView.alpha = 0
        }
    }
}
