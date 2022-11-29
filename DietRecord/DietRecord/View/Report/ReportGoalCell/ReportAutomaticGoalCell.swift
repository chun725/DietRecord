//
//  ReportGoalCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit
import SwiftUI

class ReportAutomaticGoalCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderButton: UIButton!
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
    private let agePickerView = UIPickerView()
    private let heightPickerView = UIPickerView()
    private let weightPickerView = UIPickerView()
    private var selectedHeight: String = "" {
        didSet {
            heightTextField.text = selectedHeight + "." + selectedHeightPoint
        }
    }
    private var selectedHeightPoint: String = "" {
        didSet {
            heightTextField.text = selectedHeight + "." + selectedHeightPoint
        }
    }
    private var selectedWeight: String = "" {
        didSet {
            weightTextField.text = selectedWeight + "." + selectedWeightPoint
        }
    }
    private var selectedWeightPoint: String = "" {
        didSet {
            weightTextField.text = selectedWeight + "." + selectedWeightPoint
        }
    }
    
    func layoutCell() {
        setDataSourceAndDelegate(pickerViews: [agePickerView, heightPickerView, weightPickerView])
        ageTextField.inputView = agePickerView
        heightTextField.inputView = heightPickerView
        weightTextField.inputView = weightPickerView
        agePickerView.selectRow(25, inComponent: 0, animated: false)
        heightPickerView.selectRow(160, inComponent: 0, animated: false)
        weightPickerView.selectRow(50, inComponent: 0, animated: false)
        buttonAddTargent(buttons: [genderButton, activityButton, dietGoalButton, dietPlanButton])
        textFieldAddTarget(textFields: [ageTextField, heightTextField, weightTextField])
    }
    
    @objc func setPersonalInfo() {
        self.personalInfo = PersonalInfo(
            gender: genderTextField.text ?? "",
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
    
    private func setDataSourceAndDelegate(pickerViews: [UIPickerView]) {
        for pickerView in pickerViews {
            pickerView.dataSource = self
            pickerView.delegate = self
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView == agePickerView ? 1 : 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case agePickerView:
            return 100
        default:
            if component == 0 {
                return 300
            } else {
                return 10
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case agePickerView:
            self.ageTextField.text = String(row)
        case heightPickerView:
            if component == 0 {
                self.selectedHeight = String(row)
            } else {
                self.selectedHeightPoint = String(row)
            }
        default:
            if component == 0 {
                self.selectedWeight = String(row)
            } else {
                self.selectedWeightPoint = String(row)
            }
        }
    }
    
    private func buttonAddTargent(buttons: [UIButton]) {
        for button in buttons {
            button.addTarget(self, action: #selector(presentAlert), for: .touchUpInside)
        }
    }
    
    @objc private func presentAlert(sender: UIButton) {
        var alertTitle = ""
        var actionTitles: [String] = []
        var textField = genderTextField
        switch sender {
        case genderButton:
            alertTitle = AlertTitle.gender.rawValue
            actionTitles = Gender.allCases.map { $0.rawValue }
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
        controller?.present(alert, animated: true)
    }
}
