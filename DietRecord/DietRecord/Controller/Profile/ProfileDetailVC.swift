//
//  ProfileDetailVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var profileDetailTableView: UITableView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var userSelfIDLabel: UILabel!
    @IBOutlet weak var responseButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    
    var mealRecord: MealRecord? {
        didSet {
            guard let userData = userData else { return }
            responses = mealRecord?.response.filter { !(userData.blocks.contains($0.person)) } ?? []
        }
    }
    var responses: [Response] = []
    var nowUserData: User?
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.loadImage(userData?.userImageURL)
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        profileDetailTableView.dataSource = self
        profileDetailTableView.delegate = self
        profileDetailTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
        self.tabBarController?.tabBar.isHidden = true
        responseTextView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func goBackProfilePage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func createResponse(_ sender: Any) {
        guard let mealRecord = mealRecord else { return }
        profileProvider.postResponse(
            postUserID: mealRecord.userID,
            date: mealRecord.date,
            meal: mealRecord.meal,
            response: responseTextView.text) { result in
                switch result {
                case .success:
                    self.mealRecord?.response.append(Response(person: userID, response: self.responseTextView.text))
                    self.profileDetailTableView.reloadData()
                    self.responseTextView.text = ""
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
        let optionAction = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
            guard var mealRecord = self.mealRecord else { return }
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
                            self.navigationController?.popViewController(animated: false)
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
                        self.profileDetailTableView.reloadData()
                    case .failure(let error):
                        print("Error Info: \(error) in deleting response.")
                    }
                }
            }
            if mealRecord.userID == userID || mealRecord.response[indexPath.row].person == userID {
                optionMenu.addAction(deleteOption)
            }
            if mealRecord.response[indexPath.row].person != userID {
                optionMenu.addAction(reportAction)
                optionMenu.addAction(blockAction)
            }
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: false)
            completionHandler(true)
        }
        optionAction.image = UIImage(systemName: "exclamationmark.bubble")
        let trailingSwipeConfiguration = UISwipeActionsConfiguration(actions: [optionAction])
        switch indexPath.section {
        case 0:
            return nil
        default:
            return trailingSwipeConfiguration
        }
    }
}

extension ProfileDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            responseButton.isEnabled = false
            responseButton.setTitleColor(.drGray, for: .normal)
        } else {
            responseButton.isEnabled = true
            responseButton.setTitleColor(.drDarkGray, for: .normal)
        }
    }
}
