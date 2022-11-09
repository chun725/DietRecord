//
//  ReportSetGoalCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit

class ReportSetGoalCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var carbsTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    
    weak var controller: SetupGoalVC?
    
    func layoutCell() {
        setTextFieldDelegate(textFields: [
            caloriesTextField,
            carbsTextField,
            proteinTextField,
            fatTextField
        ])
    }
    
    private func setTextFieldDelegate(textFields: [UITextField]) {
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var text = textField.text else { return }
        text = text.transformToDouble().format()
        switch textField {
        case caloriesTextField:
            controller?.goal[0] = text
        case carbsTextField:
            controller?.goal[1] = text
        case proteinTextField:
            controller?.goal[2] = text
        default:
            controller?.goal[3] = text
        }
    }
}
