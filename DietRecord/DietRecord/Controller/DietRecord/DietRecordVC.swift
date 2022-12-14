//
//  ViewController.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit
import WidgetKit

class DietRecordVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint! {
        didSet {
            titleLabelHeightConstraint.constant = self.navigationController?.navigationBar.frame.height ?? 0.0
        }
    }
    @IBOutlet weak var dietRecordTableView: UITableView! {
        didSet {
            dietRecordTableView.dataSource = self
            dietRecordTableView.registerCellWithNib(identifier: CaloriesPieChartCell.reuseIdentifier, bundle: nil)
            dietRecordTableView.registerCellWithNib(identifier: DietRecordCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var createDietRecordButton: UIButton! {
        didSet {
            createDietRecordButton.addTarget(self, action: #selector(goToDietInputPage), for: .touchUpInside)
        }
    }
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.text = DRConstant.dateFormatter.string(from: Date())
            changeDate()
        }
    }
    
    private var dietContentView: UIView?
    
    private var meals: [MealRecord] = []
    
    private var totalFoods: [Food] = []
    
    private var isLoading = true // 讓tableView在loading時被清掉
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        dietRecordTableView.reloadData()
    }
    
    // MARK: - Action -
    @objc func goToDietInputPage(sender: UIButton) {
        if let dietInputPage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: DietInputVC.reuseIdentifier) as? DietInputVC {
            if sender != createDietRecordButton {
                dietInputPage.mealRecord = self.meals[sender.tag]
            } else {
                dietInputPage.date = self.dateTextField.text
            }
            dietInputPage.closure = { [weak self] date in
                self?.dateTextField.text = date
                self?.changeDate()
            }
            hidesBottomBarWhenPushed = true
            DispatchQueue.main.async { [weak self] in
                self?.hidesBottomBarWhenPushed = false
            }
            self.navigationController?.pushViewController(dietInputPage, animated: true)
        }
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        if let chooseDatePage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: ChooseDateVC.reuseIdentifier) as? ChooseDateVC {
            chooseDatePage.date = self.dateTextField.text
            chooseDatePage.closure = { [weak self] date in
                if self?.dateTextField.text != date {
                    self?.dateTextField.text = date
                    self?.changeDate()
                }
            }
            self.present(chooseDatePage, animated: false)
        }
    }
    
    @objc func changeDate() {
        DRProgressHUD.show()
        self.isLoading = true
        self.meals = []
        guard let date = dateTextField.text else { return }
        FirebaseManager.shared.fetchDietRecord(date: date) { [weak self] dietRecord in
            guard let self = self else { return }
            self.isLoading = false
            DRProgressHUD.dismiss()
            
            if let dietRecord = dietRecord {
                self.meals = dietRecord.mealRecord.sorted { $0.meal < $1.meal }
                self.totalFoods = self.meals.map { $0.foods }.flatMap { $0 }
            } else {
                self.meals = []
                self.totalFoods = []
            }
            
            self.changeDietImage()
            if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.dietRecord.rawValue) ?? false {
                self.goToDietInputPage(sender: self.createDietRecordButton)
                DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.dietRecord.rawValue)
            }
        }
    }
    
    // MARK: - DietWidget -
    func changeDietImage() {
        self.dietRecordTableView.reloadData()
        self.dietRecordTableView.layoutIfNeeded()
        if dateTextField.text == DRConstant.dateFormatter.string(from: Date()) {
            guard let image = self.dietContentView?.takeScreenshot(),
                let imageData = try? DRConstant.encoder.encode(image.pngData())
            else { fatalError("Could not find the image of diet pie chart view.") }
                DRConstant.groupUserDefaults?.set(
                DRConstant.dateFormatter.string(from: Date()),
                forKey: GroupUserDefault.dietDate.rawValue)
                DRConstant.groupUserDefaults?.set(
                imageData,
                forKey: GroupUserDefault.dietImage.rawValue)
            WidgetCenter.shared.reloadTimelines(ofKind: GroupUserDefault.secondWidgetName.rawValue)
        }
    }
    
    // MARK: - TableViewDataSource -
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 0
        } else {
            return section == 0 ? 1 : meals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CaloriesPieChartCell.reuseIdentifier,
                for: indexPath) as? CaloriesPieChartCell,
                let userData = DRConstant.userData
            else { fatalError("Could not create calories pie chart cell.") }
            let carbs = DRConstant.calculateMacroNutrition(foods: totalFoods, nutrient: .carbohydrate)
            let protein = DRConstant.calculateMacroNutrition(foods: totalFoods, nutrient: .protein)
            let fat = DRConstant.calculateMacroNutrition(foods: totalFoods, nutrient: .lipid)
            cell.controller = self
            cell.layoutCell(carbs: carbs, protein: protein, fat: fat)
            cell.setPieChart(
                breakfast: DRConstant.calculateMacroNutrition(
                    foods: meals.first { $0.meal == 0 }?.foods,
                    nutrient: .calories),
                lunch: DRConstant.calculateMacroNutrition(
                    foods: meals.first { $0.meal == 1 }?.foods,
                    nutrient: .calories),
                dinner: DRConstant.calculateMacroNutrition(
                    foods: meals.first { $0.meal == 2 }?.foods,
                    nutrient: .calories),
                others: DRConstant.calculateMacroNutrition(
                    foods: meals.first { $0.meal == 3 }?.foods,
                    nutrient: .calories),
                goal: userData.goal[0].transformToDouble())
            self.dietContentView = cell.contentView
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DietRecordCell.reuseIdentifier,
                for: indexPath) as? DietRecordCell
            else { fatalError("Could not create diet record cell.") }
            cell.editButton.addTarget(self, action: #selector(goToDietInputPage), for: .touchUpInside)
            cell.editButton.tag = indexPath.row
            let mealRecord = meals[indexPath.row]
            switch mealRecord.meal {
            case 0:
                cell.mealLabel.text = Meal.breakfast.rawValue
                cell.mealLabel.backgroundColor = .drYellow
            case 1:
                cell.mealLabel.text = Meal.lunch.rawValue
                cell.mealLabel.backgroundColor = .drGreen
            case 2:
                cell.mealLabel.text = Meal.dinner.rawValue
                cell.mealLabel.backgroundColor = .drOrange
            default:
                cell.mealLabel.text = Meal.others.rawValue
                cell.mealLabel.backgroundColor = .drDarkBlue
            }
            cell.layoutCell(mealRecord: mealRecord)
            return cell
        }
    }
}
