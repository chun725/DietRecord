//
//  FoodSearchVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchVC: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var foodInputTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    let foodListProvider = FoodListProvider()
    
    var foodSearchResults: [FoodIngredient] = [] {
        didSet {
            searchResultTableView.reloadData()
        }
    }
    
    var chooseFoods: [Food] = [] {
        didSet {
            searchResultTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
        foodInputTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        foodInputTextField.resignFirstResponder()
    }
    
    @objc func goToFoodNutritionPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            foodNutritionPage.food = foodSearchResults[sender.tag]
            self.navigationController?.pushViewController(foodNutritionPage, animated: false)
        }
    }
    
    @IBAction func goBackToDietInputPage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let foodName = textField.text else { return }
        foodListProvider.fetchFoods(foodName: foodName) { result in
            switch result {
            case .success(let foods):
                self.foodSearchResults = foods
            case .failure(let error):
                print("Error Info: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? foodSearchResults.count : chooseFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodSearchResultCell.reuseidentifier,
            for: indexPath) as? FoodSearchResultCell
        else { fatalError("Could not create food search result cell.") }
        let food = foodSearchResults[indexPath.row]
        cell.layoutCell(food: food)
        cell.detailButton.addTarget(self, action: #selector(goToFoodNutritionPage), for: .touchUpInside)
        cell.detailButton.tag = indexPath.row
        cell.backgroundColor = .clear
        return cell
    }
}
