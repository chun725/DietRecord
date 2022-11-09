//
//  TabBarController.swift
//  DietRecord
//
//  Created by chun on 2022/11/1.
//

import UIKit

class TabBarController: UITabBarController {
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDateformatter()
        fetchFoodIngredient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSelfData()
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
    
    func fetchSelfData() {
        profileProvider.fetchUserData(userID: userID) { result in
            switch result {
            case .success(let user):
                userData = user
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
}
