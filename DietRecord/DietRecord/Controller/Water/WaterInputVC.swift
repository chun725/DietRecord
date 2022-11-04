//
//  WaterInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class WaterInputVC: UIViewController {
    @IBOutlet weak var allBackgroundView: UIView!
    @IBOutlet weak var waterInputBackgroundView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var grayBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var waterInputView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var waterCurrent: Double?
    var closure: ((Double) -> Void)?
    var isWaterInput = true
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allBackgroundView.layer.cornerRadius = 20
        waterInputBackgroundView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 20
        grayBackgroundView.layer.cornerRadius = 20
        if isWaterInput {
            titleLabel.text = "輸入飲水量"
            imageView.image = UIImage(named: "Image_Water")
            timePicker.isHidden = true
            saveButton.addTarget(self, action: #selector(saveWaterRecord), for: .touchUpInside)
        } else {
            titleLabel.text = "設定喝水提醒"
            imageView.image = UIImage(named: "Image_Reminder")
            waterInputView.isHidden = true
            saveButton.addTarget(self, action: #selector(saveReminder), for: .touchUpInside)
        }
    }
    
    @objc func saveWaterRecord() {
        guard let addWater = inputTextField.text?.transformToDouble(),
            let waterCurrent = waterCurrent
        else { return }
        let totalWater = addWater + waterCurrent
        waterRecordProvider.updateWaterRecord(totalWater: totalWater.formatNoPoint()) { result in
            switch result {
            case .success:
                self.closure?(totalWater)
            case .failure(let error):
                print("Error Info: \(error).")
            }
            self.dismiss(animated: false)
        }
    }
    
    @objc func saveReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🔔 在忙碌的同時也要記得喝水哦！"
        content.badge = 1
        content.sound = UNNotificationSound.default
        timeDateFormatter.dateFormat = "HH:mm"
        let timeString = timeDateFormatter.string(from: timePicker.date)
        let time = timeString.components(separatedBy: ":")
        guard let hour = Int(time[0]),
            let minute = Int(time[1])
        else { return }
        let dateComponent = DateComponents(timeZone: .current, hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(
            identifier: waterReminderNotification + timeString,
            content: content,
            trigger: trigger)
        var reminders = userDefault.array(forKey: waterReminder) as? [String]
        if reminders == nil {
            userDefault.set([timeString], forKey: waterReminder)
        } else {
            reminders?.append(timeString)
            userDefault.set(reminders, forKey: waterReminder)
        }
        UNUserNotificationCenter.current().add(request)
        self.closure?(0.0)
        self.dismiss(animated: false)
    }
    
    @IBAction func goBackToWaterPage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
