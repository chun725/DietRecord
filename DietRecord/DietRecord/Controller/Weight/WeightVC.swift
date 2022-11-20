//
//  WeightVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit
import HealthKit
import CoreMIDI

class WeightVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var weightLineChart: UIView!
    @IBOutlet weak var weightTableView: UITableView!
    @IBOutlet weak var changeGoalButton: UIButton!
    @IBOutlet weak var weightGoalLabel: UILabel!
    @IBOutlet weak var syncSwitch: UISwitch!
    
    var weightRecord: [WeightData] = [] {
        didSet {
            lineChart?.setWeightLineChart(datas: weightRecord, goal: weightGoal)
            weightTableView.reloadData()
        }
    }
    var weightGoal: Double = 0.0 {
        didSet {
            lineChart?.setWeightLineChart(datas: weightRecord, goal: weightGoal)
            weightGoalLabel.text = "目標體重 \(weightGoal.format()) kg"
        }
    }
    var lineChart: LineChart?
    let healthManager = HealthKitManager()
    let weightRecordProvider = WeightRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart = LineChart(frame: .zero, superview: weightLineChart)
        weightTableView.dataSource = self
        weightTableView.delegate = self
        self.getHealthKitPermission()
        
        syncSwitch.addTarget(self, action: #selector(changeSync), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchWeightRecord()
        self.weightGoal = userData?.weightGoal.transformToDouble() ?? 0.0
    }
    
    func getHealthKitPermission() {
        healthManager.authorizeHealthKit { authorized, error -> Void in
            if authorized {
                userDefault.set(true, forKey: weightPermission)
                self.setWeight()
                DispatchQueue.main.async {
                    self.syncSwitch.isOn = true
                }
            } else {
                if error != nil, let error = error {
                    print(error)
                }
                userDefault.set(false, forKey: weightPermission)
                self.fetchWeightRecord()
                DispatchQueue.main.async {
                    self.syncSwitch.isOn = false
                }
                print("Permission denied.")
            }
        }
    }
    
    func setWeight() {
        guard let weightSample = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }

        // Call HealthKitManager's getSample() method to get the user's height.
        self.healthManager.getWeight(sampleType: weightSample) { userWeight, error -> Void in
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
            
            self.weightRecordProvider.updateWeightRecord(weightDatas: weightDatas) { result in
                switch result {
                case .success:
                    self.fetchWeightRecord()
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        }
    }
    
    @objc func changeSync() {
        if self.syncSwitch.isOn {
            userDefault.set(true, forKey: weightPermission)
        } else {
            userDefault.set(false, forKey: weightPermission)
        }
        fetchWeightRecord()
    }
    
    func fetchWeightRecord() {
        LKProgressHUD.show()
        weightRecordProvider.fetchWeightRecord(sync: self.syncSwitch.isOn) { result in
            switch result {
            case .success(let weightDatas):
                LKProgressHUD.dismiss()
                self.weightRecord = weightDatas
            case .failure(let error):
                LKProgressHUD.showFailure(text: "無法讀取體重資料")
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goToWeightInputVC(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: weight, bundle: nil)
        if let weightInputPage = storyboard.instantiateViewController(withIdentifier: "\(WeightInputVC.self)")
            as? WeightInputVC {
            if sender == changeGoalButton {
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
        if indexPath.row == weightRecord.count - 1 ||
            weightData.value == weightRecord.reversed()[indexPath.row + 1].value {
            cell.increaseView.isHidden = true
            cell.reduceView.isHidden = true
        } else if weightData.value < weightRecord.reversed()[indexPath.row + 1].value {
            cell.increaseView.isHidden = true
        } else {
            cell.reduceView.isHidden = true
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
            self.weightRecordProvider.deleteWeightRecord(weightData: weightData) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        let index = self.weightRecord.count - indexPath.row - 1
                        self.weightRecord.remove(at: index)
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
            completionHandler(true)
        }
        let trailingSwipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return trailingSwipeConfiguration
    }
}
