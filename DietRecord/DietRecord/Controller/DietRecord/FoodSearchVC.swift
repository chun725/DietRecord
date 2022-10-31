//
//  FoodSearchVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchVC: UIViewController, UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate {
    @IBOutlet weak var foodInputTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    let foodListProvider = FoodListProvider()
    
    var closure: (([Food]) -> Void)?
    
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
        searchResultTableView.delegate = self
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
    
    @IBAction func saveFoods(_ sender: Any) {
        self.closure?(chooseFoods)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func goToFoodNutritionPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            foodNutritionPage.food = foodSearchResults[sender.tag]
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods.append(food)
            }
            self.navigationController?.pushViewController(foodNutritionPage, animated: false)
        }
    }
    
    @objc func modifyQtyOfFood(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            foodNutritionPage.chooseFood = chooseFoods[sender.tag]
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods[sender.tag] = food
            }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? foodSearchResults.count : chooseFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodSearchResultCell.reuseidentifier,
            for: indexPath) as? FoodSearchResultCell
        else { fatalError("Could not create food search result cell.") }
        cell.backgroundColor = .clear
        cell.detailButton.tag = indexPath.row
        cell.detailButton.removeTarget(nil, action: nil, for: .touchUpInside)
        switch indexPath.section {
        case 0:
            let food = foodSearchResults[indexPath.row]
            cell.layoutResultCell(food: food)
            cell.detailButton.addTarget(self, action: #selector(goToFoodNutritionPage), for: .touchUpInside)
        case 1:
            let chooseFood = chooseFoods[indexPath.row]
            cell.layoutChooseCell(food: chooseFood)
            cell.detailButton.addTarget(self, action: #selector(modifyQtyOfFood), for: .touchUpInside)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "搜尋結果" : "已選擇的食物"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
}
