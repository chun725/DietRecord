//
//  UIColor+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

private enum DRColor: String {
    case drLightYellow
    case drYellow
    case drGreen
    case drOrange
    case drBlue
    case drDarkBlue
    case drLightGray
    case drGray
    case drDarkGray
}

extension UIColor {
    static let drLightYellow = DRColor(.drLightYellow)
    static let drYellow = DRColor(.drYellow)
    static let drGreen = DRColor(.drGreen)
    static let drOrange = DRColor(.drOrange)
    static let drBlue = DRColor(.drBlue)
    static let drDarkBlue = DRColor(.drDarkBlue)
    static let drLightGray = DRColor(.drLightGray)
    static let drGray = DRColor(.drGray)
    static let drDarkGray = DRColor(.drDarkGray)
    
    private static func DRColor(_ color: DRColor) -> UIColor {
        guard let DRcolor = UIColor(named: color.rawValue) else { return .gray}
        return DRcolor
    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
