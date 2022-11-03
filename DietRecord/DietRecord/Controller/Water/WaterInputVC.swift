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
    }
    
    @IBAction func goBackToWaterPage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
