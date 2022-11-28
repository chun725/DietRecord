//
//  FoodSearchVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var foodInputTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    private let foodListProvider = DietRecordProvider()
    
    var closure: (([Food]) -> Void)?
    
    private var foodSearchResults: [FoodIngredient] = [] {
        didSet {
            searchResultTableView.reloadData()
        }
    }
    
    var oldfoods: [Food] = []
    
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
        if !oldfoods.isEmpty {
            chooseFoods = oldfoods
        }
        saveButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Action -
    @IBAction func saveFoods(_ sender: Any) {
        self.closure?(chooseFoods)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func goToFoodNutritionPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: DRConstant.dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            foodNutritionPage.newFood = foodSearchResults[sender.tag]
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods.append(food)
            }
            self.navigationController?.pushViewController(foodNutritionPage, animated: false)
        }
    }
    
    @objc func modifyQtyOfFood(sender: UIButton) {
        let storyboard = UIStoryboard(name: DRConstant.dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            foodNutritionPage.chooseFood = chooseFoods[sender.tag]
            foodNutritionPage.isModify = true
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods[sender.tag] = food
            }
            self.navigationController?.pushViewController(foodNutritionPage, animated: false)
        }
    }
    
    @IBAction func goBackToDietInputPage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - TextFieldDelegate -
    func textFieldDidBeginEditing(_ textField: UITextField) {
        foodSearchResults = []
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let foodName = textField.text else { return }
        if !foodName.isEmpty {
            foodListProvider.searchFoods(foodName: foodName) { result in
                switch result {
                case .success(let foods):
                    if foods.isEmpty {
                        DRProgressHUD.showFailure(text: "無此食物")
                    } else {
                        self.foodSearchResults = foods
                    }
                case .failure(let error):
                    print("Error Info: \(error)")
                }
            }
        }
    }
    
    // MARK: - TableViewDataSource -
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? foodSearchResults.count : chooseFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodSearchResultCell.reuseIdentifier,
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
    
    // MARK: - TableViewDelegate -
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "搜尋結果" : "已選擇的食物"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.headerView(forSection: 0)?.contentView.backgroundColor = .drLightGray
        tableView.headerView(forSection: 1)?.contentView.backgroundColor = .drLightGray
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { _, _, completionHandler in
            self.chooseFoods.remove(at: indexPath.row)
            self.searchResultTableView.reloadData()
            completionHandler(true)
        }
        let trailingSwipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        switch indexPath.section {
        case 0:
            return nil
        default:
            return trailingSwipeConfiguration
        }
    }
}
