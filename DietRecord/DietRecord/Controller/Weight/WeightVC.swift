//
//  WeightVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var addWeightRecordButton: UIBarButtonItem!
    @IBOutlet weak var weightLineChart: UIView!
    @IBOutlet weak var changeGoalButton: UIButton!
    @IBOutlet weak var weightGoalLabel: UILabel!
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var weightTableView: UITableView! {
        didSet {
            weightTableView.dataSource = self
            weightTableView.delegate = self
        }
    }
    @IBOutlet weak var syncSwitch: UISwitch! {
        didSet {
            syncSwitch.addTarget(self, action: #selector(changeSync), for: .valueChanged)
        }
    }
    @IBOutlet weak var healthAppImageView: UIImageView! {
        didSet {
            healthAppImageView.setBorder(width: 0.5, color: .drGray, radius: 10)
        }
    }
    
    var weightRecord: [WeightData] = []
    var weightGoal: Double = DRConstant.userData?.weightGoal.transformToDouble() ?? 0.0 {
        didSet {
            lineChart?.setWeightLineChart(datas: weightRecord, goal: weightGoal)
            weightGoalLabel.text = "目標體重 \(weightGoal.format()) kg"
        }
    }
    var lineChart: LineChart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart = LineChart(frame: .zero, superview: weightLineChart)
        weightGoalLabel.text = "目標體重 \(weightGoal.format()) kg"
        self.haveGetHealthKitPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchWeightRecord()
        FirebaseManager.shared.healthManager.havePermissionOfWrite { [weak self] bool in
            self?.syncSwitch.isOn = bool
        }
    }
    
    private func haveGetHealthKitPermission() {
        FirebaseManager.shared.healthManager.haveGetPermission { result in
            switch result {
            case .success(let index):
                if index != 2 {
                    self.getHealthKitPermission()
                } else {
                    self.setWeight()
                }
            case .failure(let error):
                print("Error Info: \(error) in get permission of healthkit.")
            }
        }
    }
    
    private func getHealthKitPermission() {
        FirebaseManager.shared.healthManager.authorizeHealthKit { authorized, error -> Void in
            if authorized {
                DRConstant.userDefault.set(true, forKey: DRConstant.weightPermission)
                self.setWeight()
                DispatchQueue.main.async {
                    self.syncSwitch.setOn(true, animated: false)
                }
            } else {
                if error != nil, let error = error {
                    print(error)
                }
                DRConstant.userDefault.set(false, forKey: DRConstant.weightPermission)
                self.syncSwitch.setOn(false, animated: false)
                self.fetchWeightRecord()
                print("Permission denied.")
            }
        }
    }
    
    private func setWeight() {
        guard let weightSample = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }

        // Call HealthKitManager's getSample() method to get the user's height.
        FirebaseManager.shared.healthManager.getWeight(sampleType: weightSample) { userWeight, error -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            var weightDatas: [WeightData] = []
            
            guard let weightDatasInHealth = userWeight as? [HKQuantitySample] else { return }
            
            for weight in weightDatasInHealth {
                let weightData = WeightData(
                    date: weight.endDate,
                    value: weight.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)),
                    dataSource: WeightDataSource.healthApp.rawValue)
                weightDatas.append(weightData)
            }
            
            FirebaseManager.shared.updateWeightRecord(weightDatas: weightDatas) {
                self.fetchWeightRecord()
            }
        }
    }
    
    @objc func changeSync() {
        FirebaseManager.shared.healthManager.havePermissionOfWrite { bool in
            if bool {
                DRConstant.userDefault.set(self.syncSwitch.isOn, forKey: DRConstant.weightPermission)
                self.fetchWeightRecord()
            } else {
                if self.syncSwitch.isOn {
                    let alert = UIAlertController(
                        title: "未開啟寫入權限",
                        message: "請去設定 -> 隱私權與安全性 -> 健康 -> 食話實說，開啟寫入數據的功能",
                        preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    self.syncSwitch.isOn = false
                } else {
                    self.fetchWeightRecord()
                }
                DRConstant.userDefault.set(false, forKey: DRConstant.weightPermission)
            }
        }
    }
    
    private func fetchWeightRecord() {
        DRProgressHUD.show()
        FirebaseManager.shared.fetchWeightRecord(sync: self.syncSwitch.isOn) { [weak self] weightRecords in
            guard let self = self else { return }
            DRProgressHUD.dismiss()
            self.weightRecord = weightRecords
            self.lineChart?.setWeightLineChart(datas: self.weightRecord, goal: self.weightGoal)
            self.weightTableView.reloadData()
            self.presentView(views: [self.healthAppImageView, self.syncLabel, self.syncSwitch])
            
            if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.weight.rawValue) ?? false {
                guard let addWeightRecordButton = self.addWeightRecordButton else { return }
                self.goToWeightInputVC(addWeightRecordButton)
                DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.weight.rawValue)
            }
        }
    }
    
    // MARK: - Action -
    @IBAction func goToWeightInputVC(_ sender: Any) {
        if let weightInputPage = UIStoryboard.weight.instantiateViewController(
            withIdentifier: WeightInputVC.reuseIdentifier) as? WeightInputVC {
            if sender as? UIButton == changeGoalButton {
                weightInputPage.isSetGoal = true
                weightInputPage.closure = { [weak self] weight in
                    self?.weightGoal = weight
                }
            } else {
                weightInputPage.closure = { [weak self] _ in
                    self?.fetchWeightRecord()
                }
            }
            self.present(weightInputPage, animated: false)
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weightRecord.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeightCell.reuseIdentifier, for: indexPath) as? WeightCell
        else { fatalError("Could not create the weight cell.") }
        let weightData = weightRecord.reversed()[indexPath.row]
        cell.layoutCell(weightData: weightData)
        if indexPath.row == weightRecord.count - 1 {
            cell.hiddenView(views: [cell.flatView, cell.increaseView, cell.reduceView])
        } else if weightData.value == weightRecord.reversed()[indexPath.row + 1].value {
            cell.hiddenView(views: [cell.increaseView, cell.reduceView])
        } else if weightData.value < weightRecord.reversed()[indexPath.row + 1].value {
            cell.hiddenView(views: [cell.flatView, cell.increaseView])
        } else {
            cell.hiddenView(views: [cell.flatView, cell.reduceView])
        }
        return cell
    }
    
    // MARK: - TableViewDelegate -
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "體重記錄"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.contentView.backgroundColor = .drLightGray
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { _, _, completionHandler in
            let weightData = self.weightRecord.reversed()[indexPath.row]
            FirebaseManager.shared.deleteWeightRecord(weightData: weightData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        let index = self.weightRecord.count - indexPath.row - 1
                        self.weightRecord.remove(at: index)
                        UIView.animate(withDuration: 0.5) {
                            self.weightTableView.beginUpdates()
                            self.weightTableView.deleteRows(at: [indexPath], with: .fade)
                            self.weightTableView.endUpdates()
                        }
                        self.lineChart?.setWeightLineChart(datas: self.weightRecord, goal: self.weightGoal)
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
            completionHandler(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "編輯") { _, _, completionHandler in
            let weightData = self.weightRecord.reversed()[indexPath.row]
            if let weightInputPage = UIStoryboard.weight.instantiateViewController(
                withIdentifier: WeightInputVC.reuseIdentifier) as? WeightInputVC {
                weightInputPage.date = DRConstant.dateFormatter.string(from: weightData.date)
                weightInputPage.weight = weightData.value
                weightInputPage.closure = { [weak self] _ in
                    self?.fetchWeightRecord()
                }
                self.present(weightInputPage, animated: false)
            }
            completionHandler(true)
        }
        let trailingSwipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return trailingSwipeConfiguration
    }
}
