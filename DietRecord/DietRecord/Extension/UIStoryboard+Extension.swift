//
//  UIStoryboard+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/12/13.
//

import UIKit

private enum StoryboardCategory {
    static let main = "Main"
    static let water = "Water"
    static let weight = "Weight"
    static let dietRecord = "DietRecord"
    static let report = "Report"
    static let profile = "Profile"
}

extension UIStoryboard {
    static var main: UIStoryboard { return drStoryboard(name: StoryboardCategory.main) }
    static var water: UIStoryboard { return drStoryboard(name: StoryboardCategory.water) }
    static var weight: UIStoryboard { return drStoryboard(name: StoryboardCategory.weight) }
    static var dietRecord: UIStoryboard { return drStoryboard(name: StoryboardCategory.dietRecord) }
    static var report: UIStoryboard { return drStoryboard(name: StoryboardCategory.report) }
    static var profile: UIStoryboard { return drStoryboard(name: StoryboardCategory.profile) }

    private static func drStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
