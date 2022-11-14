//
//  ViewController.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class DietRecordVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var dietRecordTableView: UITableView!
    @IBOutlet weak var createDietRecordButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var meals: [MealRecord] = [] {
        didSet {
            meals = meals.sorted { $0.meal < $1.meal }
            totalFoods = meals.map { $0.foods }.flatMap { $0 }
        }
    }
    
    var totalFoods: [Food]? {
        didSet {
            dietRecordTableView.reloadData()
        }
    }
    
    var isLoading = true // 讓tableView在loading時被清掉
    
    let dietRecordProvider = DietRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dietRecordTableView.dataSource = self
        dietRecordTableView.registerCellWithNib(identifier: CaloriesPieChartCell.reuseIdentifier, bundle: nil)
        dietRecordTableView.registerCellWithNib(identifier: DietRecordCell.reuseIdentifier, bundle: nil)
        dateTextField.text = dateFormatter.string(from: Date())
        changeDate()
        createDietRecordButton.addTarget(self, action: #selector(goToDietInputPage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dietRecordTableView.reloadData()
    }
    
    @objc func goToDietInputPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let dietInputPage = storyboard.instantiateViewController(withIdentifier: "\(DietInputVC.self)")
            as? DietInputVC {
            if sender != createDietRecordButton {
                dietInputPage.mealRecord = self.meals[sender.tag]
            }
            dietInputPage.closure = { [weak self] date in
                self?.dateTextField.text = date
                self?.changeDate()
            }
            self.navigationController?.pushViewController(dietInputPage, animated: false)
        }
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let chooseDatePage = storyboard.instantiateViewController(withIdentifier: "\(ChooseDateVC.self)")
            as? ChooseDateVC {
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
        LKProgressHUD.show()
        self.isLoading = true
        self.meals = []
        guard let date = dateTextField.text else { return }
        dietRecordProvider.fetchDietRecord(date: date) { result in
            switch result {
            case .success(let data):
                self.isLoading = false
                if data as? String == "Document doesn't exist." {
                    LKProgressHUD.dismiss()
                    self.placeholderLabel.isHidden = false
                    self.meals = []
                } else {
                    guard let dietRecordData = data as? FoodDailyInput else { return }
                    self.meals = dietRecordData.mealRecord
                    LKProgressHUD.dismiss()
                    if self.meals.isEmpty {
                        self.placeholderLabel.isHidden = false
                    } else {
                        self.placeholderLabel.isHidden = true
                    }
                }
            case .failure(let error):
                LKProgressHUD.showFailure(text: "找不到飲食紀錄")
                print("Error Info: \(error).")
            }
        }
    }
    
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
                let userData = userData
            else { fatalError("Could not create calories pie chart cell.") }
            let calories = calculateMacroNutrition(foods: totalFoods, nutrient: .calories)
            let carbs = calculateMacroNutrition(foods: totalFoods, nutrient: .carbohydrate)
            let protein = calculateMacroNutrition(foods: totalFoods, nutrient: .protein)
            let fat = calculateMacroNutrition(foods: totalFoods, nutrient: .lipid)
            cell.layoutCell(
                calories: "\(calories.format())/\(userData.goal[0]) kcal",
                carbs: "\(carbs.format())/\(userData.goal[1]) g",
                protein: "\(protein.format())/\(userData.goal[2]) g",
                fat: "\(fat.format())/\(userData.goal[3]) g")
            cell.setPieChart(
                breakfast: calculateMacroNutrition(foods: meals.first { $0.meal == 0 }?.foods, nutrient: .calories),
                lunch: calculateMacroNutrition(foods: meals.first { $0.meal == 1 }?.foods, nutrient: .calories),
                dinner: calculateMacroNutrition(foods: meals.first { $0.meal == 2 }?.foods, nutrient: .calories),
                others: calculateMacroNutrition(foods: meals.first { $0.meal == 3 }?.foods, nutrient: .calories),
                goal: userData.goal[0].transformToDouble())
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
