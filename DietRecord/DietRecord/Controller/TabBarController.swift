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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = DRConstant.groupUserDefaults?.integer(forKey: "OpenWithWidget") {
            switch index {
            case 1:
                self.selectedIndex = 0
            default:
                self.selectedIndex = 2
            }
            DRConstant.groupUserDefaults?.set(0, forKey: "OpenWithWidget")
        } else {
            self.selectedIndex = 2
        }
    }
}
