//
//  User.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import Foundation

struct User: Codable {
    let user: String
    let following: [String]
}
