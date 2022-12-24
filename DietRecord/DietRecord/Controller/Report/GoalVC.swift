//
//  GoalVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit

class GoalVC: UIViewController {
    @IBOutlet weak var whiteBackgroundView: UIView! {
        didSet {
            whiteBackgroundView.setShadowAndRadius(radius: 10)
        }
    }
    @IBOutlet weak var fatLabel: UILabel! {
        didSet {
            fatLabel.text = DRConstant.userData?.goal[3].transform(unit: Units.gUnit.rawValue)
        }
    }
    @IBOutlet weak var proteinLabel: UILabel! {
        didSet {
            proteinLabel.text = DRConstant.userData?.goal[2].transform(unit: Units.gUnit.rawValue)
        }
    }
    @IBOutlet weak var carbsLabel: UILabel! {
        didSet {
            carbsLabel.text = DRConstant.userData?.goal[1].transform(unit: Units.gUnit.rawValue)
        }
    }
    
    @IBOutlet weak var caloriesLabel: UILabel! {
        didSet {
            caloriesLabel.text = DRConstant.userData?.goal[0].transform(unit: Units.kcalUnit.rawValue)
        }
    }
    @IBOutlet weak var inputButton: UIButton! {
        didSet {
            inputButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
            inputButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var automaticButton: UIButton! {
        didSet {
            automaticButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
            automaticButton.layer.cornerRadius = 10
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func goToSetupGoalVC(sender: UIButton) {
        if let setupGoalPage = UIStoryboard.report.instantiateViewController(
            withIdentifier: SetupGoalVC.reuseIdentifier) as? SetupGoalVC {
            if sender == inputButton {
                setupGoalPage.isAutomatic = false
            }
            setupGoalPage.closure = { [weak self] goal in
                self?.caloriesLabel.text = goal[0].transform(unit: Units.kcalUnit.rawValue)
                self?.carbsLabel.text = goal[1].transform(unit: Units.gUnit.rawValue)
                self?.proteinLabel.text = goal[2].transform(unit: Units.gUnit.rawValue)
                self?.fatLabel.text = goal[3].transform(unit: Units.gUnit.rawValue)
            }
            hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(setupGoalPage, animated: true)
        }
    }
}
