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
        
        if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.water.rawValue) ?? false {
            self.selectedIndex = 0
        } else if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.report.rawValue) ?? false {
            self.selectedIndex = 3
        } else if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.dietRecord.rawValue) ?? false {
            self.selectedIndex = 2
        } else if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.weight.rawValue) ?? false {
            self.selectedIndex = 1
        }
    }
}
