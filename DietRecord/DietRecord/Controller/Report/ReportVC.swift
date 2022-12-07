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
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint!
    
    var refreshControl: UIRefreshControl?
    var weeklyDietRecord: [FoodDailyInput]? {
        didSet {
            reportTableView.reloadData()
        }
    }
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.text = DRConstant.dateFormatter.string(from: Date())
        fetchWeeklyDiet(sender: nil)
        reportTableView.dataSource = self
        reportTableView.registerCellWithNib(identifier: ReportDetailCell.reuseIdentifier, bundle: nil)
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        reportTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchWeeklyDiet), for: .valueChanged)
        titleLabelHeightConstraint.constant = self.navigationController?.navigationBar.frame.height ?? 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        reportTableView.reloadData()
        DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.report.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.dietRecord, bundle: nil)
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
            let date = DRConstant.dateFormatter.date(from: dateString)
        else { return }
        
        FirebaseManager.shared.fetchWeeklyDietRecord(date: date) { [weak self] weeklyDietRecord in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            self.isLoading = false
            DRProgressHUD.dismiss()
            self.weeklyDietRecord = weeklyDietRecord
        }
    }
    
    @IBAction func goToGoalPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.report, bundle: nil)
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
                let goal = DRConstant.userData?.goal[0],
                let date = dateTextField.text
            else { fatalError("Could not create report bar chart cell.") }
            cell.setBarChart(date: date, foodDailyInputs: weeklyDietRecord, goal: goal.transformToDouble())
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportDetailCell.reuseIdentifier, for: indexPath) as? ReportDetailCell,
                let userData = DRConstant.userData
            else { fatalError("Could not create report detail cell.") }
            cell.layoutCell(foodDailyInputs: weeklyDietRecord)
            let goal = userData.goal
            cell.layoutOfGoal(goal: goal)
            return cell
        }
    }
}
