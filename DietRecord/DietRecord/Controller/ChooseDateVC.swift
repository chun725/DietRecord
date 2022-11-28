//
//  ChooseDateVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import UIKit

class ChooseDateVC: UIViewController {
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var chooseDateButton: UIButton!
    @IBOutlet weak var grayBackgroundView: UIView!
    
    var date: String?
    var closure: ((String) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut) {
                self.dateView.transform = CGAffineTransform(translationX: 0, y: -self.dateView.frame.height)
                self.grayBackgroundView.transform = CGAffineTransform(translationX: 0, y: -self.dateView.frame.height)
        }
        dateView.layer.cornerRadius = 15
        chooseDateButton.layer.cornerRadius = 10
        if let date = date {
            datePicker.date = DRConstant.dateFormatter.date(from: date) ?? Date()
        }
    }
    
    @IBAction func chooseDate(_ sender: Any) {
        let animations = {
            self.dateView.transform = CGAffineTransform(translationX: 0, y: self.dateView.frame.height)
            self.grayBackgroundView.transform = CGAffineTransform(translationX: 0, y: self.dateView.frame.height)
            self.blackView.alpha = 0
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: animations) { _ in
                self.closure?(DRConstant.dateFormatter.string(from: self.datePicker.date))
                self.dismiss(animated: false)
        }
    }
}
