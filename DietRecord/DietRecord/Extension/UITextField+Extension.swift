//
//  UITextField+Extension.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

class NoPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) { return false }
        return super.canPerformAction(action, withSender: sender)
    }
}
