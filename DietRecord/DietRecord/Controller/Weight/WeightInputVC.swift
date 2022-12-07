//
//  WeightInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/4.
//

import UIKit
import HealthKit

class WeightInputVC: UIViewController {
    @IBOutlet weak var blackBackgroundView: UIView!
    @IBOutlet weak var allBackgroundView: UIView!
    @IBOutlet weak var grayBackgroundView: UIView!
    @IBOutlet weak var weightInputTextField: UITextField!
    @IBOutlet weak var weightInputView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var setGoalLabel: UILabel!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var chooseDateButton: UIButton!
    
    let healthKitManager = HealthKitManager()
    var isSetGoal = false
    var date: String?
    var weight: Double?
    var closure: ((Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grayBackgroundView.layer.cornerRadius = 20
        saveButton.layer.cornerRadius = 20
        allBackgroundView.layer.cornerRadius = 20
        weightInputView.layer.cornerRadius = 10
        dateLabel.text = DRConstant.dateFormatter.string(from: Date())
        setGoalLabel.isHidden = !isSetGoal
        chooseDateButton.isEnabled = !isSetGoal
        dateStackView.isHidden = isSetGoal
        if let date = date, let weight = weight {
            dateLabel.text = date
            weightInputTextField.text = String(weight)
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
    
    @IBAction func goToChooseDatePage(_ sender: Any) {
        let storyboard = UIStoryboard(name: DRConstant.dietRecord, bundle: nil)
        if let chooseDatePage = storyboard.instantiateViewController(withIdentifier: "\(ChooseDateVC.self)")
            as? ChooseDateVC {
            if let date = date {
                chooseDatePage.date = date
            }
            chooseDatePage.isWeightInput = true
            chooseDatePage.closure = { [weak self] date in
                self?.dateLabel.text = date
            }
            present(chooseDatePage, animated: false)
        }
    }
    
    @IBAction func saveWeightRecord(_ sender: Any) {
        guard let weight = weightInputTextField.text?.transformToDouble(),
            let dateString = dateLabel.text,
            let date = DRConstant.dateFormatter.date(from: dateString)
        else { return }
        if isSetGoal {
            FirebaseManager.shared.updateWeightGoal(weightGoal: weight.format()) {
                DispatchQueue.main.async {
                    DRProgressHUD.showSuccess()
                    DRConstant.userData?.weightGoal = weight.format()
                    self.closure?(weight)
                    self.dismissAnimation()
                }
            }
        } else {
            let weightData = WeightData(date: date, value: weight, dataSource: WeightDataSource.dietRecord.rawValue)
            FirebaseManager.shared.createWeightRecord(weightData: weightData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        DRProgressHUD.showSuccess()
                        self.closure?(0.0)
                        self.dismissAnimation()
                    }
                case .failure(let error):
                    DRProgressHUD.showFailure(text: "儲存失敗")
                    print("Error Info: \(error).")
                }
            }
        }
    }
    
    @IBAction func goBackToWeightPage(_ sender: Any) {
        self.dismissAnimation()
    }
}
