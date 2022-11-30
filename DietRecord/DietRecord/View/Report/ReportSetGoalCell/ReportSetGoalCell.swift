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
        if !text.isEmpty {
            text = text.transformToDouble().format()
            if text != "0.0" {
                switch textField {
                case caloriesTextField:
                    controller?.goal[0] = text
                    textField.text = text.transform(unit: Units.kcalUnit.rawValue)
                case carbsTextField:
                    controller?.goal[1] = text
                    textField.text = text.transform(unit: Units.gUnit.rawValue)
                case proteinTextField:
                    controller?.goal[2] = text
                    textField.text = text.transform(unit: Units.gUnit.rawValue)
                default:
                    controller?.goal[3] = text
                    textField.text = text.transform(unit: Units.gUnit.rawValue)
                }
            } else {
                controller?.presentInputAlert(title: "目標不可為0或輸入格式錯誤\n請重新填寫")
                textField.text = ""
            }
        }
    }
}
