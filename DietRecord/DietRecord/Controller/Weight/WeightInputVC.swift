//
//  WeightInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/4.
//

import UIKit
import HealthKit

class WeightInputVC: UIViewController {
    @IBOutlet weak var allBackgroundView: UIView!
    @IBOutlet weak var grayBackgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var weightInputTextField: UITextField!
    @IBOutlet weak var weightInputView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    let weightRecordProvider = WeightRecordProvider()
    let healthKitManager = HealthKitManager()
    var closure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grayBackgroundView.layer.cornerRadius = 20
        saveButton.layer.cornerRadius = 20
        allBackgroundView.layer.cornerRadius = 20
        weightInputView.layer.cornerRadius = 10
    }
    
    @IBAction func saveWeightRecord(_ sender: Any) {
        guard let weight = weightInputTextField.text?.transformToDouble() else { return }
        let weightData = WeightData(date: datePicker.date, value: weight)
        weightRecordProvider.createWeightRecord(weightData: weightData) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.closure?()
                    self.dismiss(animated: false)
                }
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goBackToWeightPage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
