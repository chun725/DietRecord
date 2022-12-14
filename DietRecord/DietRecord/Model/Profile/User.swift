//
//  User.swift
//  DietRecord
//
//  Created by chun on 2022/11/7.
//

import Foundation

struct User: Codable {
    let userID: String
    var userSelfID: String
    var following: [String]
    var followers: [String]
    var blocks: [String]
    var request: [String]
    var userImageURL: String
    var username: String
    var goal: [String]
    var waterGoal: String
    var weightGoal: String
}
