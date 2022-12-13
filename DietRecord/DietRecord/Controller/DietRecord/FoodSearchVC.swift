//
//  FoodSearchVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var foodInputTextField: UITextField! {
        didSet {
            foodInputTextField.delegate = self
        }
    }
    @IBOutlet weak var searchResultTableView: UITableView! {
        didSet {
            searchResultTableView.dataSource = self
            searchResultTableView.delegate = self
            searchResultTableView.registerCellWithNib(identifier: FoodSearchPagingCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var foodSearchResults: [FoodIngredient] = [] {
        didSet {
            pages = foodSearchResults.count / 10
            lastPageCount = foodSearchResults.count % 10
            nowPage = 0
            searchResultTableView.reloadData()
        }
    }
    var pages: Int = 0
    var lastPageCount: Int = 0
    var nowPage: Int = 0
    var closure: (([Food]) -> Void)?
    var oldfoods: [Food] = []
    var chooseFoods: [Food] = [] {
        didSet {
            searchResultTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !oldfoods.isEmpty {
            chooseFoods = oldfoods
        }
    }
    
    // MARK: - Action -
    @IBAction func saveFoods(_ sender: Any) {
        self.closure?(chooseFoods)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goToFoodNutritionPage(sender: UIButton) {
        if let foodNutritionPage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: FoodNutritionVC.reuseIdentifier) as? FoodNutritionVC {
            foodNutritionPage.newFood = foodSearchResults[nowPage * 10 + sender.tag]
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods.append(food)
            }
            self.navigationController?.pushViewController(foodNutritionPage, animated: true)
        }
    }
    
    @objc func modifyQtyOfFood(sender: UIButton) {
        if let foodNutritionPage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: FoodNutritionVC.reuseIdentifier) as? FoodNutritionVC {
            foodNutritionPage.chooseFood = chooseFoods[sender.tag]
            foodNutritionPage.isModify = true
            foodNutritionPage.closure = { [weak self] (food: Food) in
                self?.chooseFoods[sender.tag] = food
            }
            self.navigationController?.pushViewController(foodNutritionPage, animated: true)
        }
    }
    
    // MARK: - TextFieldDelegate -
    func textFieldDidBeginEditing(_ textField: UITextField) {
        foodSearchResults = []
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var foodName = textField.text else { return }
        let substring = foodName.split(separator: " ")
        foodName = substring.joined(separator: "")
        textField.text = foodName
        if !foodName.isEmpty {
            FirebaseManager.shared.searchFoods(foodName: foodName) { foodSearchResults in
                if foodSearchResults.isEmpty {
                    DRProgressHUD.showFailure(text: "無此食物")
                } else {
                    self.foodSearchResults = foodSearchResults
                }
            }
        }
    }
    
    // MARK: - TableViewDataSource -
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if foodSearchResults.count > 10 {
                if nowPage != pages {
                    return 11
                } else {
                    return lastPageCount + 1
                }
            } else {
                return foodSearchResults.count
            }
        } else {
            return chooseFoods.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath != IndexPath(row: 10, section: 0) &&
            !(nowPage == pages && indexPath == IndexPath(row: lastPageCount, section: 0)) {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FoodSearchResultCell.reuseIdentifier,
                for: indexPath) as? FoodSearchResultCell
            else { fatalError("Could not create food search result cell.") }
            cell.backgroundColor = .clear
            cell.detailButton.tag = indexPath.row
            cell.detailButton.removeTarget(nil, action: nil, for: .touchUpInside)
            switch indexPath.section {
            case 0:
                let food = foodSearchResults[nowPage * 10 + indexPath.row]
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
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FoodSearchPagingCell.reuseIdentifier,
                for: indexPath) as? FoodSearchPagingCell
            else { fatalError("Could not create food search paging cell.") }
            cell.backgroundColor = .clear
            cell.controller = self
            cell.layoutCell()
            return cell
        }
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
