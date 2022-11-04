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
    @IBOutlet weak var weightCurrentLabel: UILabel!
    @IBOutlet weak var weightTableView: UITableView!
    
    var weightRecord: [WeightData] = [] {
        didSet {
            lineChart?.setWeightLineChart(datas: weightRecord, goal: 52)
            let lastWeight = weightRecord.last?.value
            weightCurrentLabel.text = lastWeight?.format().transform(unit: kgUnit)
            weightTableView.reloadData()
        }
    }
    
    var lineChart: LineChart?
    let healthManager = HealthKitManager()
    let weightRecordProvider = WeightRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart = LineChart(frame: .zero, superview: weightLineChart)
        lineChart?.setWeightLineChart(datas: weightRecord, goal: 52)
        weightTableView.dataSource = self
        weightTableView.delegate = self
        getHealthKitPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchWeightRecord()
    }
    
    func getHealthKitPermission() {
        healthManager.authorizeHealthKit { authorized, error -> Void in
            if authorized {
                self.setWeight()
            } else {
                if error != nil, let error = error {
                    print(error)
                }
                self.fetchWeightRecord()
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
                    value: weight.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))
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
    
    func fetchWeightRecord() {
        weightRecordProvider.fetchWeightRecord { result in
            switch result {
            case .success(let weightDatas):
                self.weightRecord = weightDatas
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goToWeightInputVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: weight, bundle: nil)
        if let weightInputPage = storyboard.instantiateViewController(withIdentifier: "\(WeightInputVC.self)")
            as? WeightInputVC {
            weightInputPage.closure = { [weak self] in
                self?.fetchWeightRecord()
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
        "體重紀錄"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
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
