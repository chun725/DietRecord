//
//  ProfileInformationVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/15.
//

import UIKit

class ProfileInformationVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var profileInfoTableView: UITableView! {
        didSet {
            profileInfoTableView.dataSource = self
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.addTarget(self, action: #selector(createUserInfo), for: .touchUpInside)
            saveButton.layer.cornerRadius = 20
        }
    }
    
    var isUpdated = false
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isUpdated {
            self.user = DRConstant.userData
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func createUserInfo() {
        guard let user = user else { return }
        if user.userSelfID.isEmpty || user.username.isEmpty || user.weightGoal.isEmpty
            || user.waterGoal.isEmpty || user.goal.isEmpty {
            self.presentInputAlert(title: "請輸入完整資料")
        } else {
            DRProgressHUD.show()
            FirebaseManager.shared.createUserInfo(userData: user) { [weak self] in
                guard let self = self else { return }
                DRConstant.userData = user
                DRProgressHUD.showSuccess()
                if !self.isUpdated {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileInformationCell.reuseIdentifier, for: indexPath) as? ProfileInformationCell
        else { fatalError("Could not create the profile information cell.") }
        if isUpdated {
            guard let userData = DRConstant.userData else { fatalError("Could not find user data.") }
            cell.user = userData
            cell.goal = userData.goal
        }
        cell.controller = self
        cell.layoutCell()
        return cell
    }
}
