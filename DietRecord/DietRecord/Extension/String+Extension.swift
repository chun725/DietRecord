//
//  String+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import Foundation

extension String {
    func transformToDouble() -> Double {
        guard let double = Double(self) else { return 0.0 }
        return double
    }
    
    func transform(unit: String) -> String {
        if !self.isEmpty && self != "nan" {
            return "\(self) \(unit)"
        } else {
            return "-"
        }
    }
}
