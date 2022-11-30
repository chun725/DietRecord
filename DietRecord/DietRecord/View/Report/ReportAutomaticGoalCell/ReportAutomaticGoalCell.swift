//
//  ReportGoalCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit
import SwiftUI

class ReportAutomaticGoalCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var activityButton: UIButton!
    @IBOutlet weak var activityTextField: UITextField!
    @IBOutlet weak var dietGoalTextField: UITextField!
    @IBOutlet weak var dietGoalButton: UIButton!
    @IBOutlet weak var dietPlanTextField: UITextField!
    @IBOutlet weak var dietPlanButton: UIButton!
    
    weak var controller: SetupGoalVC?
    var personalInfo: PersonalInfo? {
        didSet {
            controller?.personalInfo = personalInfo
        }
    }

    func layoutCell() {
        buttonAddTargent(buttons: [activityButton, dietGoalButton, dietPlanButton])
        textFieldAddTarget(textFields: [ageTextField, heightTextField, weightTextField])
        genderSegmentedControl.addTarget(self, action: #selector(setPersonalInfo), for: .valueChanged)
    }
    
    @objc func setPersonalInfo() {
        self.personalInfo = PersonalInfo(
            gender: genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex) ?? "",
            age: ageTextField.text ?? "",
            height: heightTextField.text ?? "",
            weight: weightTextField.text ?? "",
            activityLevel: activityTextField.text ?? "",
            dietGoal: dietGoalTextField.text ?? "",
            dietPlan: dietPlanTextField.text ?? "")
    }
    
    private func textFieldAddTarget(textFields: [UITextField]) {
        for textField in textFields {
            textField.addTarget(self, action: #selector(setPersonalInfo), for: .editingDidEnd)
        }
    }
    
    private func buttonAddTargent(buttons: [UIButton]) {
        for button in buttons {
            button.addTarget(self, action: #selector(presentAlert), for: .touchUpInside)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var text = textField.text else { return }
        if  (textField == ageTextField || textField == heightTextField || textField == weightTextField) && !text.isEmpty {
            text = text.transformToDouble().format()
            if text != "0.0" {
                textField.text = text
            } else {
                switch textField {
                case ageTextField:
                    controller?.presentInputAlert(title: "年齡不可為0\n請重新填寫")
                case heightTextField:
                    controller?.presentInputAlert(title: "身高不可為0\n請重新填寫")
                default:
                    controller?.presentInputAlert(title: "體重不可為0\n請重新填寫")
                }
                textField.text = ""
            }
        }
    }
    
    @objc private func presentAlert(sender: UIButton) {
        var alertTitle = ""
        var actionTitles: [String] = []
        var textField = activityTextField
        switch sender {
        case activityButton:
            alertTitle = AlertTitle.activityLevel.rawValue
            actionTitles = ActivityLevel.allCases.map { $0.rawValue }
            textField = activityTextField
        case dietGoalButton:
            alertTitle = AlertTitle.dietGoal.rawValue
            actionTitles = DietGoal.allCases.map { $0.rawValue }
            textField = dietGoalTextField
        default:
            alertTitle = AlertTitle.dietPlan.rawValue
            actionTitles = DietPlan.allCases.map { $0.rawValue }
            textField = dietPlanTextField
        }
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        for actionTitle in actionTitles {
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                textField?.text = actionTitle
                self.setPersonalInfo()
            }
            alert.addAction(action)
        }
        alert.view.tintColor = .drDarkGray
        controller?.present(alert, animated: true)
    }
}
