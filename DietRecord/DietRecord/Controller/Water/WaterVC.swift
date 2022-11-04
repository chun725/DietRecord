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
    
    var reminders = userDefault.array(forKey: waterReminder) as? [String] {
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
    
    @objc func goToWaterInputVC(sender: UIButton) {
        let storyboard = UIStoryboard(name: water, bundle: nil)
        if let waterInputPage = storyboard.instantiateViewController(withIdentifier: "\(WaterInputVC.self)")
            as? WaterInputVC {
            if sender.tag == 1 {
                waterInputPage.isWaterInput = false
                waterInputPage.closure = { [weak self] _ in
                    self?.reminders = userDefault.array(forKey: waterReminder) as? [String]
                }
            } else {
                waterInputPage.waterCurrent = self.waterCurrent
                waterInputPage.closure = { [weak self] totalWater in
                    self?.waterCurrent = totalWater
                }
            }
            self.present(waterInputPage, animated: false)
        }
    }
    
    @objc func deleteReminder(sender: UIButton) {
        guard var reminders = reminders else { return }
        let time = reminders[sender.tag]
        reminders.remove(at: sender.tag)
        userDefault.set(reminders, forKey: waterReminder)
        self.reminders = userDefault.array(forKey: waterReminder) as? [String]
        print(waterReminderNotification + time)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [waterReminderNotification + time])
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reminders = reminders else { return section == 0 ? 1 : 0 }
        return section == 0 ? 1 : reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TotalWaterCell.reuseIdentifier, for: indexPath) as? TotalWaterCell
            else { fatalError("Could not create the total water cell.")}
            cell.layoutCell(water: waterCurrent, goal: waterGoal)
            cell.addWaterButton.addTarget(self, action: #selector(goToWaterInputVC), for: .touchUpInside)
            cell.addReminderButton.tag = 1
            cell.addReminderButton.addTarget(self, action: #selector(goToWaterInputVC), for: .touchUpInside)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WaterReminderCell.reuseIdentifier, for: indexPath) as? WaterReminderCell,
                let reminders = reminders
            else { fatalError("Could not create the water reminder cell.") }
            let time = reminders[indexPath.row]
            cell.layoutCell(time: time)
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deleteReminder), for: .touchUpInside)
            return cell
        }
    }
}
