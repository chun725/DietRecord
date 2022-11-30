//
//  UIView+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

extension UIView {
    func stickSubview(_ objectView: UIView) {
        objectView.removeFromSuperview()
        addSubview(objectView)
        objectView.translatesAutoresizingMaskIntoConstraints = false
        objectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        objectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        objectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        objectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func setShadowAndRadius(radius: Double) {
        self.layer.cornerRadius = radius
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 2
        self.layer.shadowColor = UIColor.drGray.cgColor
        self.layer.shadowOpacity = 0.5
    }
    
    func setBorder(width: CGFloat, color: UIColor, radius: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
    }
    
    func takeScreenshot() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        }
        return UIImage()
    }
}
