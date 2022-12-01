//
//  WaterVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit
import WidgetKit

class WaterVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var waterTableView: UITableView!
        
    var pieChartView: PieChart?
    
    var waterCurrent: Double = 0.0
    
    var waterGoal: Double = DRConstant.userData?.waterGoal.transformToDouble() ?? 0.0
    
    var reminders = DRConstant.userDefault.array(forKey: DRConstant.waterReminder) as? [String] {
        didSet {
            waterTableView.reloadData()
        }
    }
    
    var isLoading = true
    
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waterTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWaterRecord()
    }
    
    @IBAction func goToHistoryPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.water, bundle: nil)
        if let waterHistoryPage = storyboard.instantiateViewController(withIdentifier: "\(WaterHistoryVC.self)")
            as? WaterHistoryVC {
            present(waterHistoryPage, animated: false)
        }
    }
    
    // MARK: - WaterWidget -
    func changeImage() {
        guard let image = self.pieChartView?.takeScreenshot(),
            let imageData = try? DRConstant.encoder.encode(image.pngData())
        else { fatalError("Could not find the image of water pie chart view.") }
            DRConstant.groupUserDefaults?.set(
            DRConstant.dateFormatter.string(from: Date()),
            forKey: GroupUserDefault.waterDate.rawValue)
            DRConstant.groupUserDefaults?.set(
            imageData,
            forKey: GroupUserDefault.waterImage.rawValue)
        WidgetCenter.shared.reloadTimelines(ofKind: GroupUserDefault.firstWidgetName.rawValue)
    }
    
    @objc func goToWaterInputVC(sender: UIButton?) {
        let storyboard = UIStoryboard(name: DRConstant.water, bundle: nil)
        if let waterInputPage = storyboard.instantiateViewController(withIdentifier: "\(WaterInputVC.self)")
            as? WaterInputVC {
            if let sender = sender, sender.tag == 1 {
                waterInputPage.isWaterInput = false
                waterInputPage.closure = { [weak self] _ in
                    self?.reminders = DRConstant.userDefault.array(forKey: DRConstant.waterReminder) as? [String]
                }
            } else {
                waterInputPage.waterCurrent = self.waterCurrent
                waterInputPage.closure = { [weak self] totalWater in
                    self?.waterCurrent = totalWater
                    self?.waterTableView.reloadData()
                    self?.waterTableView.layoutIfNeeded()
                    self?.changeImage()
                }
            }
            self.present(waterInputPage, animated: false)
        }
    }
    
    @objc func deleteReminder(sender: UIButton) {
        guard var reminders = reminders else { return }
        let time = reminders[sender.tag]
        reminders.remove(at: sender.tag)
        DRConstant.userDefault.set(reminders, forKey: DRConstant.waterReminder)
        self.reminders = DRConstant.userDefault.array(forKey: DRConstant.waterReminder) as? [String]
        print(DRConstant.waterReminderNotification + time)
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [DRConstant.waterReminderNotification + time])
    }
    
    func fetchWaterRecord() {
        DRProgressHUD.show()
        waterRecordProvider.fetchWaterRecord { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                DRProgressHUD.dismiss()
                self.isLoading = false
                self.waterGoal = DRConstant.userData?.waterGoal.transformToDouble() ?? 0.0
                self.waterTableView.reloadData()
                if let waterRecord = data as? WaterRecord {
                    self.waterCurrent = waterRecord.water.transformToDouble()
                }
                if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.water.rawValue) ?? false {
                    self.goToWaterInputVC(sender: nil)
                    DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.water.rawValue)
                }
            case .failure(let error):
                DRProgressHUD.showFailure(text: "無法讀取飲水量資料")
                print("Error Info: \(error)")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 0
        } else {
            guard let reminders = reminders else { return section == 0 ? 1 : 0 }
            return section == 0 ? 1 : reminders.count
        }
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
            cell.controller = self
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
