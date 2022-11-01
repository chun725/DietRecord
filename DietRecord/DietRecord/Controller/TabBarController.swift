//
//  TabBarController.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDateformatter()
        fetchFoodIngredient()
    }
    
    func fetchFoodIngredient() {
        do {
            guard let url = Bundle.main.url(forResource: foodIngredient, withExtension: "json")
            else { fatalError("Could not create the food ingredient database.") }
            let jsonDecoder = JSONDecoder()
            let savedJSONData = try Data(contentsOf: url)
            foodIngredients = try jsonDecoder.decode([FoodIngredient].self, from: savedJSONData)
        } catch {
            print("Error Info: \(error).")
        }
    }
}
