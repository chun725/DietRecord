//
//  WaterVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit
import WidgetKit

class WaterVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var waterTableView: UITableView! {
        didSet {
            waterTableView.dataSource = self
        }
    }
        
    var pieChartView: PieChart?
    var isLoading = true
    var waterCurrent: Double = 0.0
    var waterGoal: Double = DRConstant.userData?.waterGoal.transformToDouble() ?? 0.0
    var reminders = DRConstant.userDefault.array(forKey: DRConstant.waterReminder) as? [String] {
        didSet {
            waterTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWaterRecord()
    }
    
    private func fetchWaterRecord() {
        DRProgressHUD.show()
        FirebaseManager.shared.fetchWaterRecord { [weak self] waterRecord in
            guard let self = self else { return }
            DRProgressHUD.dismiss()
            self.isLoading = false
            self.waterGoal = DRConstant.userData?.waterGoal.transformToDouble() ?? 0.0
            self.waterTableView.reloadData()
            self.waterCurrent = waterRecord.water.transformToDouble()
            if DRConstant.groupUserDefaults?.bool(forKey: ShortcutItemType.water.rawValue) ?? false {
                self.goToWaterInputVC(sender: nil)
                DRConstant.groupUserDefaults?.set(false, forKey: ShortcutItemType.water.rawValue)
            }
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
    
    // MARK: - Action -
    @IBAction func goToHistoryPage(_ sender: Any) {
        if let waterHistoryPage = UIStoryboard.water.instantiateViewController(
            withIdentifier: WaterHistoryVC.reuseIdentifier) as? WaterHistoryVC {
            hidesBottomBarWhenPushed = true
            DispatchQueue.main.async { [weak self] in
                self?.hidesBottomBarWhenPushed = false
            }
            self.navigationController?.pushViewController(waterHistoryPage, animated: false)
        }
    }
    
    @objc func goToWaterInputVC(sender: UIButton?) {
        if let waterInputPage = UIStoryboard.water.instantiateViewController(
            withIdentifier: WaterInputVC.reuseIdentifier) as? WaterInputVC {
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
    
    // MARK: - TableViewDataSource -
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
