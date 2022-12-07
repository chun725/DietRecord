//
//  WaterInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import UIKit

class WaterInputVC: UIViewController {
    @IBOutlet weak var blackBackgroundView: UIView!
    @IBOutlet weak var allBackgroundView: UIView!
    @IBOutlet weak var waterInputBackgroundView: UIView!
    @IBOutlet weak var inputGrayBackgroundView: UIView!
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
    @IBOutlet weak var plusButton: UIButton! {
        didSet {
            plusButton.isHidden = isGoalInput
            plusButton.addTarget(self, action: #selector(changeWaterCurrent), for: .touchUpInside)
        }
    }
    @IBOutlet weak var minusButton: UIButton! {
        didSet {
            if let waterCurrent = waterCurrent {
                minusButton.isEnabled = waterCurrent - 100 >= 0 ? true : false
                minusButton.tintColor = waterCurrent - 100 >= 0 ? .drDarkGray : .drGray
            }
            minusButton.isHidden = isGoalInput
            minusButton.addTarget(self, action: #selector(changeWaterCurrent), for: .touchUpInside)
        }
    }
    
    var waterCurrent: Double?
    var closure: ((Double) -> Void)?
    var isWaterInput = true
    var isGoalInput = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allBackgroundView.layer.cornerRadius = 20
        inputGrayBackgroundView.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 20
        grayBackgroundView.layer.cornerRadius = 20
        if isWaterInput {
            if isGoalInput {
                titleLabel.text = "輸入飲水量目標"
                saveButton.addTarget(self, action: #selector(saveWaterGoal), for: .touchUpInside)
            } else {
                titleLabel.text = "輸入飲水量"
                saveButton.addTarget(self, action: #selector(saveWaterRecord), for: .touchUpInside)
                inputTextField.text = waterCurrent?.formatNoPoint()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.blackBackgroundView.alpha = 0.4
            self.allBackgroundView.alpha = 1
            for subview in self.allBackgroundView.subviews {
                subview.alpha = 1
            }
        }
    }
    
    private func dismissAnimation() {
        let animations = {
            self.blackBackgroundView.alpha = 0
            self.allBackgroundView.alpha = 0
            for subview in self.allBackgroundView.subviews {
                subview.alpha = 0
            }
        }
        UIView.animate(withDuration: 0.5, animations: animations) { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc func saveWaterGoal() {
        guard let waterGoal = inputTextField.text else { return }
        FirebaseManager.shared.updateWaterGoal(waterGoal: waterGoal) {
            DRProgressHUD.showSuccess()
            DRConstant.userData?.waterGoal = waterGoal
            self.closure?(waterGoal.transformToDouble())
            self.dismissAnimation()
        }
    }
    
    @objc func saveWaterRecord() {
        guard let totalWater = inputTextField.text?.transformToDouble() else { return }
        FirebaseManager.shared.updateWaterRecord(totalWater: totalWater.formatNoPoint()) {
            DRProgressHUD.showSuccess()
            self.closure?(totalWater)
            self.dismissAnimation()
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
                if minuteIndex < 10 {
                    return "\(hourIndex):0\(minuteIndex)"
                } else {
                    return "\(hourIndex):\(minuteIndex)"
                }
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
        self.dismissAnimation()
    }
    
    @objc func changeWaterCurrent(sender: UIButton) {
        guard var totalWater = inputTextField.text?.transformToDouble() else { return }
        if sender == plusButton {
            totalWater += 100
        } else {
            totalWater -= 100
        }
        inputTextField.text = totalWater.formatNoPoint()
        minusButton.isEnabled = totalWater - 100 >= 0 ? true : false
        minusButton.tintColor = totalWater - 100 >= 0 ? .drDarkGray : .drGray
    }
    
    @IBAction func goBackToWaterPage(_ sender: Any) {
        self.dismissAnimation()
    }
}

extension WaterInputVC: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - PickerViewDataSource -
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == hourPickerView ? 24 : 60
    }

    // MARK: - PickerViewDelegate -
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
