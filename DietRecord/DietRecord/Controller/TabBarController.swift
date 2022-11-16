//
//  TabBarController.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = .drDarkGray
        self.selectedIndex = 2
    }
}
