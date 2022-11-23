//
//  DietRecord.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import Foundation
import FirebaseFirestore

struct Food: Codable, Equatable {
    let qty: String
    let foodIngredient: FoodIngredient
}

struct FoodIngredient: Codable, Equatable {
    let type: String
    let serialNumber: String
    let name: String
    let englishName: String
    let commonName: String
    let contentDescription: String
    var nutrientContent: NutrientContent
    let weightPerUnit: String
}

struct NutrientContent: Codable, Equatable {
    var calories: String
    var water: String
    var protein: String
    var carbohydrate: String
    var dietaryFiber: String
    var sugar: String
    var lipid: String
    var saturatedLipid: String
    var polyunsaturatedLipid: String
    var monounsaturatedLipid: String
    var cholesterol: String
    var sodium: String
    var potassium: String
}
struct MealRecord: Codable, Equatable {
    let userID: String
    let meal: Int
    let date: String
    let foods: [Food]
    let imageURL: String?
    let comment: String
    var isShared: Bool
    let createdTime: Date
    var peopleLiked: [String]
    var response: [Response]
}

struct FoodDailyInput: Codable {
    var mealRecord: [MealRecord]
}

struct Response: Codable, Equatable {
    let person: String
    let response: String
}
