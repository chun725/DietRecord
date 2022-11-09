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
    
    let reportProvider = ReportProvider()
    var weeklyDietRecord: [FoodDailyInput]? {
        didSet {
            reportTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.addTarget(self, action: #selector(fetchWeeklyDiet), for: .valueChanged)
        fetchWeeklyDiet()
        reportTableView.dataSource = self
        reportTableView.registerCellWithNib(identifier: ReportDetailCell.reuseIdentifier, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportTableView.reloadData()
    }
    
    @objc func fetchWeeklyDiet() {
        reportProvider.fetchWeeklyDietRecord(date: datePicker.date) { result in
            switch result {
            case .success(let data):
                let weeklyDietRecordData = data as? [FoodDailyInput]
                self.weeklyDietRecord = weeklyDietRecordData
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goToGoalPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: report, bundle: nil)
        if let goalPage = storyboard.instantiateViewController(withIdentifier: "\(GoalVC.self)")
            as? GoalVC {
            self.navigationController?.pushViewController(goalPage, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportBarChartCell.reuseIdentifier, for: indexPath) as? ReportBarChartCell,
                let goal = userData?.goal[0]
            else { fatalError("Could not create report bar chart cell.") }
            let date = dateFormatter.string(from: datePicker.date)
            cell.setBarChart(date: date, foodDailyInputs: weeklyDietRecord, goal: goal.transformToDouble())
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportDetailCell.reuseIdentifier, for: indexPath) as? ReportDetailCell,
                let userData = userData
            else { fatalError("Could not create report detail cell.") }
            cell.layoutCell(foodDailyInputs: weeklyDietRecord)
            let goal = userData.goal
            cell.layoutOfGoal(goal: goal)
            return cell
        }
    }
}
