//
//  DietRecord.swift
//  DietRecord
//
//  Created by chun on 2022/10/30.
//

import Foundation

struct Food: Codable {
    let qty: String
    let foodIngredient: FoodIngredient
}

struct FoodIngredient: Codable {
    let type: String
    let serialNumber: String
    let name: String
    let englishName: String
    let commonName: String
    let contentDescription: String
    var nutrientContent: NutrientContent
    let weightPerUnit: String
}

struct NutrientContent: Codable {
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
struct MealRecord: Codable {
    let meal: Int
    let foods: [Food]
    let imageURL: String
    let comment: String
}

struct FoodDailyInput: Codable {
    let date: String
    var mealRecord: [MealRecord]
}
