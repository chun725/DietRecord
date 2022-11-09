//
//  ViewController.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class DietRecordVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var dietRecordTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var meals: [MealRecord]? {
        didSet {
            breakfastMeal = meals?.first { $0.meal == 0 }
            lunchMeal = meals?.first { $0.meal == 1 }
            dinnerMeal = meals?.first { $0.meal == 2 }
            othersMeal = meals?.first { $0.meal == 3 }
            totalFoods = meals?.map { $0.foods }.flatMap { $0 }
        }
    }
    
    var totalFoods: [Food]? {
        didSet {
            dietRecordTableView.reloadData()
        }
    }
    var breakfastMeal: MealRecord?
    var lunchMeal: MealRecord?
    var dinnerMeal: MealRecord?
    var othersMeal: MealRecord?
    
    let dietRecordProvider = DietRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dietRecordTableView.dataSource = self
        dietRecordTableView.registerCellWithNib(identifier: CaloriesPieChartCell.reuseIdentifier, bundle: nil)
        dietRecordTableView.registerCellWithNib(identifier: DietRecordCell.reuseIdentifier, bundle: nil)
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        changeDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dietRecordTableView.reloadData()
    }
    
    @objc func goToDietInputPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let dietInputPage = storyboard.instantiateViewController(withIdentifier: "\(DietInputVC.self)")
            as? DietInputVC {
            self.navigationController?.pushViewController(dietInputPage, animated: false)
        }
    }
    
    @objc func changeDate() {
        let date = datePicker.date
        dietRecordProvider.fetchDietRecord(date: dateFormatter.string(from: date)) { result in
            switch result {
            case .success(let data):
                if data as? String == "Document doesn't exist." {
                    self.meals = nil
                } else {
                    let dietRecordData = data as? FoodDailyInput
                    self.meals = dietRecordData?.mealRecord
                }
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : 4
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
                breakfast: calculateMacroNutrition(foods: breakfastMeal?.foods, nutrient: .calories),
                lunch: calculateMacroNutrition(foods: lunchMeal?.foods, nutrient: .calories),
                dinner: calculateMacroNutrition(foods: dinnerMeal?.foods, nutrient: .calories),
                others: calculateMacroNutrition(foods: othersMeal?.foods, nutrient: .calories),
                goal: userData.goal[0].transformToDouble())
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DietRecordCell.reuseIdentifier,
                for: indexPath) as? DietRecordCell
            else { fatalError("Could not create diet record cell.") }
            cell.editButton.addTarget(self, action: #selector(goToDietInputPage), for: .touchUpInside)
            let mealRecord: MealRecord?
            switch indexPath.row {
            case 0:
                mealRecord = breakfastMeal
                cell.mealLabel.text = Meal.breakfast.rawValue
                cell.mealLabel.backgroundColor = .drYellow
            case 1:
                mealRecord = lunchMeal
                cell.mealLabel.text = Meal.lunch.rawValue
                cell.mealLabel.backgroundColor = .drGreen
            case 2:
                mealRecord = dinnerMeal
                cell.mealLabel.text = Meal.dinner.rawValue
                cell.mealLabel.backgroundColor = .drOrange
            default:
                mealRecord = othersMeal
                cell.mealLabel.text = Meal.others.rawValue
                cell.mealLabel.backgroundColor = .drDarkBlue
            }
            cell.layoutCell(mealRecord: mealRecord)
            return cell
        }
    }
}
