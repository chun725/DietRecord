//
//  Date+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

let database = Firestore.firestore()
let dateFormatter = DateFormatter()
let fontName = "PingFang TC"
let foodBaseView = "FoodBaseView"
let dietRecord = "DietRecord"
let foodIngredient = "FoodIngredient"
let user = "User"
let userID = "j9UZDoOiEEIoYo0r3z9S"
let diet = "Diet"
let kcalUnit = "kcal"
let gUnit = "g"
let mgUnit = "mg"

func configureDateformatter() {
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "yyyy-MM-dd"
}

enum Meal: String {
    case breakfast = "早餐"
    case lunch = "午餐"
    case dinner = "晚餐"
    case others = "其他"
    case gap = "差異"
}

enum Water: String {
    case current = "目前飲水量"
    case gap = "與目標的差異"
}
