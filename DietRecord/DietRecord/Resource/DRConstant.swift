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
let kcalUnit = "kcal"
let gUnit = "g"
let mgUnit = "mg"

enum Result<T> {
    case success(T)
    case failure(Error)
}
