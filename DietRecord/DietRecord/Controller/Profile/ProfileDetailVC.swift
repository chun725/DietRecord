//
//  ProfileDetailVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var profileDetailTableView: UITableView! {
        didSet {
            profileDetailTableView.dataSource = self
            profileDetailTableView.delegate = self
            profileDetailTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var responseTextField: UITextField!
    @IBOutlet weak var userSelfIDLabel: UILabel!
    @IBOutlet weak var responseButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.loadImage(DRConstant.userData?.userImageURL)
            userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        }
    }
    @IBOutlet weak var responseBackgroundView: UIView! {
        didSet {
            responseBackgroundView.layer.cornerRadius = 10
        }
    }
    
    var mealRecord: MealRecord? {
        didSet {
            guard let userData = DRConstant.userData else { return }
            responses = mealRecord?.response.filter { !(userData.blocks.contains($0.person)) } ?? []
        }
    }
    var responses: [Response] = []
    var nowUserData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseTextField.addTarget(self, action: #selector(changeResponseButton), for: .allEditingEvents)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Action -
    @IBAction func createResponse(_ sender: Any) {
        guard let mealRecord = mealRecord,
            let response = responseTextField.text
        else { return }
        FirebaseManager.shared.postResponse(
            postUserID: mealRecord.userID,
            date: mealRecord.date,
            meal: mealRecord.meal,
            response: response) { [weak self] in
                guard let self = self else { return }
                self.mealRecord?.response.append(Response(person: DRConstant.userID, response: response))
                UIView.animate(withDuration: 0.5) {
                    self.profileDetailTableView.beginUpdates()
                    self.profileDetailTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    self.profileDetailTableView.insertRows(
                        at: [IndexPath(row: mealRecord.response.count, section: 1)],
                        with: .fade)
                    self.profileDetailTableView.endUpdates()
                }
                self.responseTextField.text = ""
                self.responseButton.isEnabled = false
                self.responseButton.setTitleColor(.drGray, for: .normal)
        }
    }
    
    // MARK: - TableViewDataSource -
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : responses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileDetailCell.reuseIdentifier, for: indexPath) as? ProfileDetailCell,
                let mealRecord = mealRecord
            else { fatalError("Could not create the profile detail cell.") }
            cell.controller = self
            cell.layoutCell(mealRecord: mealRecord, nowUserData: nowUserData)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileResponseCell.reuseIdentifier, for: indexPath) as? ProfileResponseCell
            else { fatalError("Could not create the profile response cell.") }
            let response = responses[indexPath.row]
            cell.controller = self
            cell.layoutCell(response: response)
            return cell
        }
    }
    
    // MARK: - TableViewDelegate -
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let optionAction = self.configureAction(indexPath: indexPath)
        optionAction.image = UIImage(systemName: "exclamationmark.bubble")
        let trailingSwipeConfiguration = UISwipeActionsConfiguration(actions: [optionAction])
        switch indexPath.section {
        case 0:
            return nil
        default:
            return trailingSwipeConfiguration
        }
    }
    
    private func configureAction(indexPath: IndexPath) -> UIContextualAction {
        let optionAction = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completionHandler in
            guard let self = self,
                var mealRecord = self.mealRecord
            else { return }
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction(title: "檢舉回覆", style: .destructive) { _ in
                FirebaseManager.shared.reportSomething(
                    user: nil,
                    mealRecord: nil,
                    response: self.responses[indexPath.row]) {
                    print("成功檢舉")
                }
            }
            let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive) { _ in
                FirebaseManager.shared.changeBlock(blockID: self.responses[indexPath.row].person) {
                    print("成功封鎖用戶")
                    if self.mealRecord?.userID == self.responses[indexPath.row].person {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.responses.remove(at: indexPath.row)
                        self.profileDetailTableView.reloadData()
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            let deleteOption = UIAlertAction(title: "刪除回覆", style: .destructive) { _ in
                FirebaseManager.shared.deletePostOrResponse(
                    mealRecord: mealRecord,
                    response: self.responses[indexPath.row]) {
                    print("成功刪除回覆")
                    let index = mealRecord.response.firstIndex(of: self.responses[indexPath.row]) ?? 0
                    mealRecord.response.remove(at: index)
                    self.mealRecord = mealRecord
                    UIView.animate(withDuration: 0.5) {
                        self.profileDetailTableView.beginUpdates()
                        self.profileDetailTableView.deleteRows(at: [indexPath], with: .fade)
                        self.profileDetailTableView.endUpdates()
                    }
                    self.profileDetailTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
            if mealRecord.userID == DRConstant.userID || self.responses[indexPath.row].person == DRConstant.userID {
                optionMenu.addAction(deleteOption)
            }
            if self.responses[indexPath.row].person != DRConstant.userID {
                optionMenu.addAction(reportAction)
                optionMenu.addAction(blockAction)
            }
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true)
            completionHandler(true)
        }
        return optionAction
    }
}

extension ProfileDetailVC {
    @objc func changeResponseButton(sender: UITextField) {
        if let text = sender.text, text.isEmpty {
            responseButton.isEnabled = false
            responseButton.setTitleColor(.drGray, for: .normal)
        } else {
            responseButton.isEnabled = true
            responseButton.setTitleColor(.drDarkGray, for: .normal)
        }
    }
}
