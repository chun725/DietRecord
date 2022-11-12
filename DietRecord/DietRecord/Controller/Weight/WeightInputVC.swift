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
    @IBOutlet weak var weightInputTextField: UITextField!
    @IBOutlet weak var weightInputView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var setGoalLabel: UILabel!
    @IBOutlet weak var dateStackView: UIStackView!
    
    let weightRecordProvider = WeightRecordProvider()
    let healthKitManager = HealthKitManager()
    var isSetGoal = false
    var closure: ((Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grayBackgroundView.layer.cornerRadius = 20
        saveButton.layer.cornerRadius = 20
        allBackgroundView.layer.cornerRadius = 20
        weightInputView.layer.cornerRadius = 10
        dateLabel.text = dateFormatter.string(from: Date())
        setGoalLabel.isHidden = !isSetGoal
        dateStackView.isHidden = isSetGoal
    }
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let chooseDatePage = storyboard.instantiateViewController(withIdentifier: "\(ChooseDateVC.self)")
            as? ChooseDateVC {
            chooseDatePage.closure = { [weak self] date in
                self?.dateLabel.text = date
            }
            present(chooseDatePage, animated: false)
        }
    }
    
    @IBAction func saveWeightRecord(_ sender: Any) {
        guard let weight = weightInputTextField.text?.transformToDouble(),
            let dateString = dateLabel.text,
            let date = dateFormatter.date(from: dateString)
        else { return }
        if isSetGoal {
            weightRecordProvider.updateWeightGoal(weightGoal: weight.format()) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        userData?.weightGoal = weight.format()
                        self.closure?(weight)
                        self.dismiss(animated: false)
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        } else {
            let weightData = WeightData(date: date, value: weight)
            weightRecordProvider.createWeightRecord(weightData: weightData) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.closure?(0.0)
                        self.dismiss(animated: false)
                    }
                case .failure(let error):
                    print("Error Info: \(error).")
                }
            }
        }
    }
    
    @IBAction func goBackToWeightPage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
