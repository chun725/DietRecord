//
//  ReportVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ReportVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reportTableView: UITableView!
    
    let dietRecordProvider = DietRecordProvider()
    var weeklyDietRecord: [FoodDailyInput]? {
        didSet {
            reportTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = Date().advanced(by: -60 * 60 * 24 * 6)
        datePicker.addTarget(self, action: #selector(fetchWeeklyDiet), for: .valueChanged)
        fetchWeeklyDiet()
        reportTableView.dataSource = self
        reportTableView.registerCellWithNib(identifier: ReportDetailCell.reuseIdentifier, bundle: nil)
    }
    
    @objc func fetchWeeklyDiet() {
        dietRecordProvider.fetchWeeklyDietRecord(date: datePicker.date) { result in
            switch result {
            case .success(let data):
                let weeklyDietRecordData = data as? [FoodDailyInput]
                self.weeklyDietRecord = weeklyDietRecordData
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportBarChartCell.reuseIdentifier, for: indexPath) as? ReportBarChartCell
            else { fatalError("Could not create report bar chart cell.") }
            let date = dateFormatter.string(from: datePicker.date)
            cell.setBarChart(date: date, foodDailyInputs: weeklyDietRecord, goal: 1800)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportDetailCell.reuseIdentifier, for: indexPath) as? ReportDetailCell
            else { fatalError("Could not create report detail cell.") }
            cell.layoutCell(foodDailyInputs: weeklyDietRecord)
            let goal = NutrientContent(
                calories: "2100",
                water: "100",
                protein: "100",
                carbohydrate: "100",
                dietaryFiber: "100",
                sugar: "100",
                lipid: "100",
                saturatedLipid: "-",
                polyunsaturatedLipid: "-",
                monounsaturatedLipid: "-",
                cholesterol: "-",
                sodium: "-",
                potassium: "-")
            cell.layoutOfGoal(goal: goal)
            return cell
        }
    }
}
