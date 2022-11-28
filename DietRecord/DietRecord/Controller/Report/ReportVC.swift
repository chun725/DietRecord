//
//  ReportVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ReportVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var dateTextField: UITextField!
    
    var refreshControl: UIRefreshControl?
    let reportProvider = ReportProvider()
    var weeklyDietRecord: [FoodDailyInput]? {
        didSet {
            reportTableView.reloadData()
        }
    }
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.text = dateFormatter.string(from: Date())
        fetchWeeklyDiet(sender: nil)
        reportTableView.dataSource = self
        reportTableView.registerCellWithNib(identifier: ReportDetailCell.reuseIdentifier, bundle: nil)
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        reportTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchWeeklyDiet), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportTableView.reloadData()
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let chooseDatePage = storyboard.instantiateViewController(withIdentifier: "\(ChooseDateVC.self)")
            as? ChooseDateVC {
            chooseDatePage.date = self.dateTextField.text
            chooseDatePage.closure = { [weak self] date in
                if self?.dateTextField.text != date {
                    self?.dateTextField.text = date
                    self?.fetchWeeklyDiet(sender: nil)
                }
            }
            self.present(chooseDatePage, animated: false)
        }
    }
    
    @objc func fetchWeeklyDiet(sender: UIRefreshControl?) {
        if sender == nil {
            DRProgressHUD.show()
        }
        isLoading = true
        guard let dateString = dateTextField.text,
            let date = dateFormatter.date(from: dateString)
        else { return }
        reportProvider.fetchWeeklyDietRecord(date: date) { result in
            self.refreshControl?.endRefreshing()
            switch result {
            case .success(let data):
                self.isLoading = false
                DRProgressHUD.dismiss()
                let weeklyDietRecordData = data as? [FoodDailyInput]
                self.weeklyDietRecord = weeklyDietRecordData
            case .failure(let error):
                DRProgressHUD.showFailure(text: "讀取飲食記錄失敗")
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
        if isLoading {
            return 0
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportBarChartCell.reuseIdentifier, for: indexPath) as? ReportBarChartCell,
                let goal = userData?.goal[0],
                let date = dateTextField.text
            else { fatalError("Could not create report bar chart cell.") }
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
