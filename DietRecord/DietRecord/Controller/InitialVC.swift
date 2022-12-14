//
//  InitialVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit
import FirebaseAuth


class InitialVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DRConstant.configureDateformatter()
        fetchFoodIngredient()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DRConstant.userData == nil {
            getUserData()
        } else {
            if let tabbarController = UIStoryboard.main.instantiateViewController(
                withIdentifier: TabBarController.reuseIdentifier)
                as? TabBarController {
                self.navigationController?.pushViewController(tabbarController, animated: false)
            }
        }
    }
    
    func getUserData() {
        if let id = Auth.auth().currentUser?.uid {
            DRConstant.userID = id
            FirebaseManager.shared.fetchUserData(userID: id) { [weak self] userData in
                guard let self = self else { return }
                if let userData = userData {
                    DRConstant.userData = userData
                    if let tabbarController = UIStoryboard.main.instantiateViewController(
                        withIdentifier: TabBarController.reuseIdentifier)
                        as? TabBarController {
                        self.navigationController?.pushViewController(tabbarController, animated: false)
                    }
                } else {
                    if let profileInfoPage = UIStoryboard.profile.instantiateViewController(
                        withIdentifier: ProfileInformationVC.reuseIdentifier)
                        as? ProfileInformationVC {
                        self.navigationController?.pushViewController(profileInfoPage, animated: false)
                    }
                }
            }
        } else {
            if let loginPage = UIStoryboard.main.instantiateViewController(
                withIdentifier: LoginVC.reuseIdentifier)
                as? LoginVC {
                self.navigationController?.pushViewController(loginPage, animated: false)
            }
        }
    }
    
    func fetchFoodIngredient() {
        do {
            guard let url = Bundle.main.url(forResource: DRConstant.foodIngredient, withExtension: "json")
            else { fatalError("Could not create the food ingredient database.") }
            let savedJSONData = try Data(contentsOf: url)
            DRConstant.foodIngredients = try DRConstant.decoder.decode([FoodIngredient].self, from: savedJSONData)
        } catch {
            print("Error Info: \(error).")
        }
    }
}
