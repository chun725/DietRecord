//
//  ProfileDetailVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var profileDetailTableView: UITableView!
    @IBOutlet weak var responseTextField: UITextField!
    @IBOutlet weak var userSelfIDLabel: UILabel!
    @IBOutlet weak var responseButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var responseBackgroundView: UIView!
    
    var mealRecord: MealRecord? {
        didSet {
            guard let userData = DRConstant.userData else { return }
            responses = mealRecord?.response.filter { !(userData.blocks.contains($0.person)) } ?? []
        }
    }
    var responses: [Response] = []
    var nowUserData: User?
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.loadImage(DRConstant.userData?.userImageURL)
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        profileDetailTableView.dataSource = self
        profileDetailTableView.delegate = self
        profileDetailTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
        responseTextField.addTarget(self, action: #selector(changeResponseButton), for: .allEditingEvents)
        responseBackgroundView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func createResponse(_ sender: Any) {
        guard let mealRecord = mealRecord,
            let response = responseTextField.text
        else { return }
        profileProvider.postResponse(
            postUserID: mealRecord.userID,
            date: mealRecord.date,
            meal: mealRecord.meal,
            response: response) { result in
                switch result {
                case .success:
                    self.mealRecord?.response.append(Response(person: DRConstant.userID, response: response))
                    UIView.animate(withDuration: 0.5) {
                        self.profileDetailTableView.beginUpdates()
                        self.profileDetailTableView.insertRows(
                            at: [IndexPath(row: mealRecord.response.count, section: 1)],
                            with: .fade)
                        self.profileDetailTableView.endUpdates()
                    }
                    self.responseTextField.text = ""
                    self.responseButton.isEnabled = false
                    self.responseButton.setTitleColor(.drGray, for: .normal)
                case .failure(let error):
                    print("Error Info: \(error).")
            }
        }
    }
    
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
            else { fatalError("Could not create the profile detail cell.") }
            let response = responses[indexPath.row]
            cell.controller = self
            cell.layoutCell(response: response)
            return cell
        }
    }
    
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
            let reportAction = UIAlertAction(title: "檢舉回覆", style: .destructive) { [weak self] _ in
                self?.profileProvider.reportSomething(
                    user: nil,
                    mealRecord: nil,
                    response: self?.responses[indexPath.row]) { result in
                    switch result {
                    case .success:
                        print("success report")
                    case .failure(let error):
                        print("Error Info: \(error) in reporting something.")
                    }
                }
            }
            let blockAction = UIAlertAction(title: "封鎖用戶", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.profileProvider.changeBlock(blockID: self.responses[indexPath.row].person) { result in
                    switch result {
                    case .success:
                        print("成功封鎖用戶")
                        if self.mealRecord?.userID == self.responses[indexPath.row].person {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.responses.remove(at: indexPath.row)
                            self.profileDetailTableView.reloadData()
                        }
                    case .failure(let error):
                        print("Error Info: \(error) in blocking user.")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            let deleteOption = UIAlertAction(title: "刪除回覆", style: .destructive) { [weak self] _ in
                self?.profileProvider.deletePostOrResponse(
                    mealRecord: mealRecord,
                    response: self?.responses[indexPath.row]) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        print("成功刪除回覆")
                        let index = mealRecord.response.firstIndex(of: self.responses[indexPath.row]) ?? 0
                        mealRecord.response.remove(at: index)
                        self.mealRecord = mealRecord
                        UIView.animate(withDuration: 0.5) {
                            self.profileDetailTableView.beginUpdates()
                            self.profileDetailTableView.deleteRows(at: [indexPath], with: .fade)
                            self.profileDetailTableView.endUpdates()
                        }
                    case .failure(let error):
                        print("Error Info: \(error) in deleting response.")
                    }
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
        if sender.text == "" {
            responseButton.isEnabled = false
            responseButton.setTitleColor(.drGray, for: .normal)
        } else {
            responseButton.isEnabled = true
            responseButton.setTitleColor(.drDarkGray, for: .normal)
        }
    }
}
