//
//  User.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import Foundation

struct User: Codable {
    let userID: String
    var following: [String]
    var followers: [String]
    var request: [String]
    let userImageURL: String
    let username: String
    var goal: [String]
    var waterGoal: String
    var weightGoal: String
}
