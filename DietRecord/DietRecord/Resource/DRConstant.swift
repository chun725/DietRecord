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
var foodIngredients: [FoodIngredient]?

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

enum MacroNutrient: String {
    case calories
    case water
    case protein
    case carbohydrate
    case dietaryFiber
    case sugar
    case lipid
}

enum MicroNutrient: String {
    case saturatedLipid
    case polyunsaturatedLipid
    case monounsaturatedLipid
    case cholesterol
    case sodium
    case potassium
}

func calculateMacroNutrition(foods: [Food]?, nutrient: MacroNutrient) -> Double {
    guard let foods = foods else { return 0.0 }
    var nutritentContent: [Double] = []
    switch nutrient {
    case .calories:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.calories.transformToDouble()
        }
    case .water:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.water.transformToDouble()
        }
    case .protein:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.protein.transformToDouble()
        }
    case .carbohydrate:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.carbohydrate.transformToDouble()
        }
    case .dietaryFiber:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.dietaryFiber.transformToDouble()
        }
    case .sugar:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.sugar.transformToDouble()
        }
    case .lipid:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.lipid.transformToDouble()
        }
    }
    return nutritentContent.reduce(0.0) { $0 + $1 }
}

func calculateMicroNutrition(foods: [Food]?, nutrient: MicroNutrient) -> Double {
    guard let foods = foods else { return 0.0 }
    var nutritentContent: [Double] = []
    switch nutrient {
    case .saturatedLipid:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.saturatedLipid.transformToDouble()
        }
    case .polyunsaturatedLipid:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.polyunsaturatedLipid.transformToDouble()
        }
    case .monounsaturatedLipid:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.monounsaturatedLipid.transformToDouble()
        }
    case .cholesterol:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.cholesterol.transformToDouble()
        }
    case .sodium:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.sodium.transformToDouble()
        }
    case .potassium:
        nutritentContent = foods.compactMap {
            $0.qty.transformToDouble() / 100 *
            $0.foodIngredient.nutrientContent.potassium.transformToDouble()
        }
    }
    return nutritentContent.reduce(0.0) { $0 + $1 }
}
