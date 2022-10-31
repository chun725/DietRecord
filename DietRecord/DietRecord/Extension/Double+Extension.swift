//
//  Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
