//
//  WaterVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class WaterVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var waterTableView: UITableView!
    
    var waterCurrent: Double = 0.0 {
        didSet {
            waterTableView.reloadData()
        }
    }
    
    var waterGoal: Double = 2000 {
        didSet {
            waterTableView.reloadData()
        }
    }
    
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waterTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWaterRecord()
    }
    
    @objc func goToWaterInputVC() {
        let storyboard = UIStoryboard(name: water, bundle: nil)
        if let waterInputPage = storyboard.instantiateViewController(withIdentifier: "\(WaterInputVC.self)")
            as? WaterInputVC {
            waterInputPage.waterCurrent = self.waterCurrent
            waterInputPage.closure = { [weak self] totalWater in
                self?.waterCurrent = totalWater
            }
            self.present(waterInputPage, animated: false)
        }
    }
    
    func fetchWaterRecord() {
        waterRecordProvider.fetchWaterRecord { result in
            switch result {
            case .success(let data):
                if let waterRecord = data as? WaterRecord {
                    self.waterCurrent = waterRecord.water.transformToDouble()
                }
            case .failure(let error):
                print("Error Info: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TotalWaterCell.reuseIdentifier, for: indexPath) as? TotalWaterCell
        else { fatalError("Could not create the total water cell.")}
        cell.layoutCell(water: waterCurrent, goal: waterGoal)
        cell.addButton.addTarget(self, action: #selector(goToWaterInputVC), for: .touchUpInside)
        return cell
    }
}
