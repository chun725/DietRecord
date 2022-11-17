//
//  InitialVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit
import FirebaseAuth

class InitialVC: UIViewController {
    let profileProvider = ProfileProvider()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDateformatter()
        fetchFoodIngredient()
        getUserData()
    }
    
    func getUserData() {
        if let id = Auth.auth().currentUser?.uid {
            userID = id
            profileProvider.fetchUserData(userID: id) { result in
                switch result {
                case .success(let result):
                    if let user = result as? User {
                        userData = user
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let tabbarController = storyboard.instantiateViewController(
                            withIdentifier: "\(TabBarController.self)")
                            as? TabBarController {
                            self.navigationController?.pushViewController(tabbarController, animated: false)
                        }
                    } else {
                        let storyboard = UIStoryboard(name: profile, bundle: nil)
                        if let profileInfoPage = storyboard.instantiateViewController(
                            withIdentifier: "\(ProfileInformationVC.self)")
                            as? ProfileInformationVC {
                            self.navigationController?.pushViewController(profileInfoPage, animated: false)
                        }
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginPage = storyboard.instantiateViewController(
                withIdentifier: "\(LoginVC.self)")
                as? LoginVC {
                self.navigationController?.pushViewController(loginPage, animated: false)
            }
        }
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
