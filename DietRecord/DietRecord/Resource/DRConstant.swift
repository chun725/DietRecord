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
import FirebaseAuth

struct DRConstant {
    static let database = Firestore.firestore()
    static let dateFormatter = DateFormatter()
    static let barChartDateFormatter = DateFormatter()
    static let timeDateFormatter = DateFormatter()
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
    static let userDefault = UserDefaults()
    static let groupUserDefaults = UserDefaults(suiteName: "group.chun.DietRecord")
    static let waterReminder = "WaterReminder"
    static let fontName = "PingFang TC"
    static let foodBaseView = "FoodBaseView"
    static let dietRecord = "DietRecord"
    static let foodIngredient = "FoodIngredient"
    static let user = "User"
    static let diet = "Diet"
    static let water = "Water"
    static let weight = "Weight"
    static let report = "Report"
    static let profile = "Profile"
    static let waterReminderNotification = "WaterReminderNotification"
    static let weightPermission = "WeightPermission"
    static var userID = ""
    static var userData: User?
    static var foodIngredients: [FoodIngredient]? // 資料庫
    static var fullScreenSize = UIScreen.main.bounds.size
    static let placeholderURL = "https://firebasestorage.googleapis.com:443/v0/b/dietmanagement-cd871.appspot.com/o/83274520-623A-4C01-9BA5-552A03254CA0.jpg?alt=media&token=d618d6e0-ffd5-4ab6-87b6-83d1c070ff04"
    
    static func configureDateformatter() {
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    static func calculateMacroNutrition(foods: [Food]?, nutrient: MacroNutrient) -> Double {
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
    
    static func calculateMicroNutrition(foods: [Food]?, nutrient: MicroNutrient) -> Double {
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
}

enum Units: String {
    case kcalUnit = "kcal"
    case kgUnit = "kg"
    case gUnit = "g"
    case mgUnit = "mg"
    case mLUnit = "mL"
}

enum Meal: String, CaseIterable {
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

enum MacroNutrient: String, CaseIterable {
    case calories = "熱量"
    case carbohydrate = "碳水化合物"
    case protein = "蛋白質"
    case lipid = "脂肪"
    case water = "水分"
    case dietaryFiber = "膳食纖維"
    case sugar = "糖"
}

enum MicroNutrient: String {
    case saturatedLipid
    case polyunsaturatedLipid
    case monounsaturatedLipid
    case cholesterol
    case sodium
    case potassium
}

enum Gender: String, CaseIterable {
    case man = "男"
    case woman = "女"
}

enum ActivityLevel: String, CaseIterable {
    case hardly = "久坐"
    case low = "輕度活動量"
    case medium = "中度活動量"
    case high = "高度活動量"
    case veryHigh = "非常高度活動量"
}

enum DietGoal: String, CaseIterable {
    case remain = "維持體重"
    case increaseMuscle = "增加肌肉"
    case loseWeight = "減少體重"
}

enum DietPlan: String, CaseIterable {
    case general = "一般飲食(55/20/25)"
    case highCarbs = "高碳水飲食(60/20/20)"
    case highProtein = "高蛋白飲食(50/25/25)"
    case athlete = "運動員飲食(55/20/25)"
    case lowCarbs = "低碳飲食(35/25/40)"
}

enum AlertTitle: String {
    case gender = "請選擇性別"
    case activityLevel = "請選擇活動程度"
    case dietGoal = "請選擇飲食目標"
    case dietPlan = "請選擇飲食計畫(碳水化合物/蛋白質/脂肪)"
}

enum GroupUserDefault: String {
    case waterDate = "WaterDate"
    case waterImage = "WaterImage"
    case dietDate = "DietDate"
    case dietImage = "DietImage"
    case firstWidgetName = "ChartViewWidget"
    case secondWidgetName = "DietPieChartWidget"
}

enum WeightDataSource: String {
    case dietRecord = "DietRecord"
    case healthApp = "HealthApp"
}
