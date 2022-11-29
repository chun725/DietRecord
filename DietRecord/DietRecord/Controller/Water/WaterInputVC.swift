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
    @IBOutlet weak var hourPickerView: UIPickerView! {
        didSet {
            hourPickerView.dataSource = self
            hourPickerView.delegate = self
        }
    }
    @IBOutlet weak var minutePickerView: UIPickerView! {
        didSet {
            minutePickerView.dataSource = self
            minutePickerView.delegate = self
        }
    }
    @IBOutlet weak var timeBackgroundView: UIView!
    
    var waterCurrent: Double?
    var closure: ((Double) -> Void)?
    var isWaterInput = true
    var isGoalInput = false
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allBackgroundView.layer.cornerRadius = 20
        waterInputBackgroundView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 20
        grayBackgroundView.layer.cornerRadius = 20
        if isWaterInput {
            if isGoalInput {
                titleLabel.text = "輸入飲水量目標"
                saveButton.addTarget(self, action: #selector(saveWaterGoal), for: .touchUpInside)
            } else {
                titleLabel.text = "輸入飲水量"
                saveButton.addTarget(self, action: #selector(saveWaterRecord), for: .touchUpInside)
            }
            imageView.image = UIImage(named: "Image_Water")
            timeBackgroundView.isHidden = true
        } else {
            titleLabel.text = "設定喝水提醒"
            imageView.image = UIImage(named: "Image_Reminder")
            waterInputView.isHidden = true
            saveButton.addTarget(self, action: #selector(saveReminder), for: .touchUpInside)
            DRConstant.timeDateFormatter.dateFormat = "HH:mm"
            let dateString = DRConstant.timeDateFormatter.string(from: Date())
            let date = dateString.components(separatedBy: ":")
            let indexHour = Int(date[0]) ?? 0
            let indexMinute = Int(date[1]) ?? 0
            hourPickerView.selectRow(indexHour, inComponent: 0, animated: false)
            minutePickerView.selectRow(indexMinute, inComponent: 0, animated: false)
        }
    }
    
    @objc func saveWaterGoal() {
        guard let waterGoal = inputTextField.text else { return }
        waterRecordProvider.updateWaterGoal(waterGoal: waterGoal) { result in
            switch result {
            case .success:
                DRProgressHUD.showSuccess()
                self.closure?(waterGoal.transformToDouble())
                DRConstant.userData?.waterGoal = waterGoal
                self.dismiss(animated: false)
            case .failure(let error):
                DRProgressHUD.showFailure(text: "儲存失敗")
                print("Error Info: \(error).")
            }
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
                DRProgressHUD.showSuccess()
                self.closure?(totalWater)
                self.dismiss(animated: false)
            case .failure(let error):
                DRProgressHUD.showFailure(text: "儲存失敗")
                print("Error Info: \(error).")
            }
        }
    }
    
    @objc func saveReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🔔 喝水時間到！"
        content.body = "在忙碌的同時也要記得補充水分唷"
        content.badge = 1
        content.sound = UNNotificationSound.default
        let hourIndex = hourPickerView.selectedRow(inComponent: 0)
        let minuteIndex = minutePickerView.selectedRow(inComponent: 0)
        let timeString: String = {
            if hourIndex < 10 {
                if minuteIndex < 10 {
                    return "0\(hourIndex):0\(minuteIndex)"
                } else {
                    return "0\(hourIndex):\(minuteIndex)"
                }
            } else {
                return "\(hourIndex):\(minuteIndex)"
            }
        }()
        let dateComponent = DateComponents(timeZone: .current, hour: hourIndex, minute: minuteIndex)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(
            identifier: DRConstant.waterReminderNotification + timeString,
            content: content,
            trigger: trigger)
        var reminders = DRConstant.userDefault.array(forKey: DRConstant.waterReminder) as? [String]
        if reminders == nil {
            DRConstant.userDefault.set([timeString], forKey: DRConstant.waterReminder)
        } else {
            reminders?.append(timeString)
            reminders = reminders?.sorted()
            DRConstant.userDefault.set(reminders, forKey: DRConstant.waterReminder)
        }
        UNUserNotificationCenter.current().add(request)
        DRProgressHUD.showSuccess()
        self.closure?(0.0)
        self.dismiss(animated: false)
    }
    
    @IBAction func goBackToWaterPage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}

extension WaterInputVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == hourPickerView ? 24 : 60
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var str = String(row)
        if row < 10 {
            str = "0" + String(row)
        }
        let font = UIFont.systemFont(ofSize: 14)
        let color = UIColor.drDarkGray
        let attributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font]
        return NSAttributedString(string: str, attributes: attributes)
    }
}
