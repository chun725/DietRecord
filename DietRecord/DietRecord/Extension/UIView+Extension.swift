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
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.drDarkGray.cgColor
        self.layer.shadowOpacity = 0.5
    }
}
