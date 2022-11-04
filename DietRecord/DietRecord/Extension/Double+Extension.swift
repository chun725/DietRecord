//
//  Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import Foundation

extension Double {
    func format() -> String {
        return String(format: "%.1f", self)
    }
    
    func formatNoPoint() -> String {
        return String(format: "%.0f", self)
    }
}
