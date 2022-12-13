//
//  GoalVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit

class GoalVC: UIViewController {
    @IBOutlet weak var whiteBackgroundView: UIView!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var inputButton: UIButton!
    @IBOutlet weak var automaticButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
        automaticButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
        self.tabBarController?.tabBar.isHidden = true
        caloriesLabel.text = DRConstant.userData?.goal[0].transform(unit: Units.kcalUnit.rawValue)
        carbsLabel.text = DRConstant.userData?.goal[1].transform(unit: Units.gUnit.rawValue)
        proteinLabel.text = DRConstant.userData?.goal[2].transform(unit: Units.gUnit.rawValue)
        fatLabel.text = DRConstant.userData?.goal[3].transform(unit: Units.gUnit.rawValue)
        whiteBackgroundView.setShadowAndRadius(radius: 10)
        inputButton.layer.cornerRadius = 10
        automaticButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
            self.navigationController?.pushViewController(setupGoalPage, animated: true)
        }
    }
}
