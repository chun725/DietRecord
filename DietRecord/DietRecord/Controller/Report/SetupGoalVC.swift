//
//  SetupGoalVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import UIKit

class SetupGoalVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selfInfoTableView: UITableView! {
        didSet {
            selfInfoTableView.dataSource = self
            selfInfoTableView.registerCellWithNib(identifier: ReportSetGoalCell.reuseIdentifier, bundle: nil)
            selfInfoTableView.registerCellWithNib(identifier: ReportAutomaticGoalCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 20
        }
    }
    
    var isAutomatic = true
    var personalInfo: PersonalInfo?
    var goal: [String] = ["", "", "", ""]
    var closure: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isAutomatic {
            titleLabel.text = "請輸入營養素目標"
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAutomatic {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportAutomaticGoalCell.reuseIdentifier, for: indexPath) as? ReportAutomaticGoalCell
            else { fatalError("Could not create the report automatic goal cell.") }
            cell.controller = self
            cell.layoutCell()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ReportSetGoalCell.reuseIdentifier, for: indexPath) as? ReportSetGoalCell
            else { fatalError("Could not create the report set goal cell.") }
            cell.controller = self
            cell.layoutCell()
            return cell
        }
    }
    
    // MARK: - Action -
    @IBAction func saveInfo(_ sender: Any) {
        if isAutomatic {
            guard let personalInfo = personalInfo,
                !personalInfo.gender.isEmpty,
                !personalInfo.age.isEmpty,
                !personalInfo.height.isEmpty,
                !personalInfo.weight.isEmpty,
                !personalInfo.activityLevel.isEmpty,
                !personalInfo.dietGoal.isEmpty,
                !personalInfo.dietPlan.isEmpty
            else {
                self.presentInputAlert(title: "輸入欄位不得為空")
                return
            }
            self.goal = calculateTDEE(personalInfo: personalInfo)
        } else {
            guard goal.first(where: { $0.isEmpty }) == nil else {
                self.presentInputAlert(title: "輸入欄位不得為空")
                return
            }
        }
        DRProgressHUD.show()
        self.closure?(goal)
        
        if DRConstant.userData == nil {
            DRProgressHUD.showSuccess()
            self.navigationController?.popViewController(animated: true)
        } else {
            FirebaseManager.shared.changeGoal(goal: goal) {
                FirebaseManager.shared.fetchUserData(userID: DRConstant.userID) { [weak self] userData in
                    guard let self = self,
                        let userData = userData
                    else { return }
                    DRConstant.userData = userData
                    DRProgressHUD.showSuccess()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func calculateTDEE(personalInfo: PersonalInfo) -> [String] {
        var bmr: Double = 0
        var tdee: Double = 0
        var finalTDEE: Double = 0
        if personalInfo.gender == "男" {
            bmr = 66 + (13.7 * personalInfo.weight.transformToDouble()
                + 5 * personalInfo.height.transformToDouble()
                - 6.8 * personalInfo.age.transformToDouble())
        } else {
            bmr = 655 + (9.6 * personalInfo.weight.transformToDouble()
                + 1.8 * personalInfo.height.transformToDouble()
                - 4.7 * personalInfo.age.transformToDouble())
        }
        
        switch personalInfo.activityLevel {
        case ActivityLevel.hardly.rawValue:
            tdee = bmr * 1.2
        case ActivityLevel.low.rawValue:
            tdee = bmr * 1.375
        case ActivityLevel.medium.rawValue:
            tdee = bmr * 1.55
        case ActivityLevel.high.rawValue:
            tdee = bmr * 1.725
        default:
            tdee = bmr * 1.9
        }
        
        switch personalInfo.dietGoal {
        case DietGoal.increaseMuscle.rawValue:
            finalTDEE = tdee + 300
        case DietGoal.loseWeight.rawValue:
            finalTDEE = tdee - 300
        default:
            finalTDEE = tdee
        }
        return calculateProportion(tdee: finalTDEE, personalInfo: personalInfo)
    }
    
    private func calculateProportion(tdee: Double, personalInfo: PersonalInfo) -> [String] {
        var proportion: [Double] = [55, 15, 30]
        
        switch personalInfo.dietPlan {
        case DietPlan.general.rawValue:
            proportion = [55, 15, 30]
        case DietPlan.highCarbs.rawValue:
            proportion = [60, 20, 20]
        case DietPlan.highProtein.rawValue:
            proportion = [50, 25, 25]
        case DietPlan.athlete.rawValue:
            proportion = [55, 20, 25]
        default:
            proportion = [35, 25, 40]
        }
        
        let goal = [
            tdee.format(),
            (tdee * proportion[0] / 100 / 4).format(),
            (tdee * proportion[1] / 100 / 4).format(),
            (tdee * proportion[2] / 100 / 9).format()
        ]
        return goal
    }
}
