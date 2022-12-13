//
//  ReportVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ReportVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var reportTableView: UITableView! {
        didSet {
            reportTableView.dataSource = self
            reportTableView.registerCellWithNib(identifier: ReportDetailCell.reuseIdentifier, bundle: nil)
            reportTableView.addSubview(refreshControl)
        }
    }
    @IBOutlet weak var dateTextField: UITextField! {
        didSet {
            dateTextField.text = DRConstant.dateFormatter.string(from: Date())
        }
    }
    @IBOutlet weak var titleLabelHeightConstraint: NSLayoutConstraint! {
        didSet {
            titleLabelHeightConstraint.constant = self.navigationController?.navigationBar.frame.height ?? 0.0
        }
    }
    
    private var isLoading = false
    private var refreshControl = UIRefreshControl()
    private var weeklyDietRecord: [FoodDailyInput]? {
        didSet {
            reportTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeeklyDiet(sender: nil)
        refreshControl.addTarget(self, action: #selector(fetchWeeklyDiet), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.report.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Action -
    @IBAction func goToChooseDatePage(_ sender: Any) {
        if let chooseDatePage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: ChooseDateVC.reuseIdentifier) as? ChooseDateVC {
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
            DRProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
            self.isLoading = false
            self.weeklyDietRecord = weeklyDietRecord
        }
    }
    
    @IBAction func goToGoalPage(_ sender: Any) {
        if let goalPage = UIStoryboard.report.instantiateViewController(
            withIdentifier: GoalVC.reuseIdentifier) as? GoalVC {
            self.navigationController?.pushViewController(goalPage, animated: false)
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isLoading ? 0 : 2
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
            cell.layoutOfGoal(goal: userData.goal)
            return cell
        }
    }
}
