//
//  CheckReqestVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/8.
//

import UIKit

class CheckRequestVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var otherUserID: String?
    var need = "Request"
    var requests: [User] = [] {
        didSet {
            requestTableView.reloadData()
        }
    }
    
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTableView.dataSource = self
        requestTableView.delegate = self
        fetchRequest()
        if need == "Followers" {
            titleLabel.text = "Followers"
        } else if need == "Following" {
            titleLabel.text = "Following"
        } else if need == "BlockUsers" {
            titleLabel.text = "封鎖名單"
        }
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        requestTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchRequest), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRequest()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func fetchRequest() {
        refreshControl?.beginRefreshing()
        var id = DRConstant.userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        FirebaseManager.shared.fetchUsersData(userID: id, need: need) { [weak self] usersData in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            self.requests = usersData
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RequestCell.reuseIdentifier, for: indexPath) as? RequestCell
        else { fatalError("Could not create the request cell.") }
        let user = requests[indexPath.row]
        if need != "Request" {
            cell.checkButton.isHidden = true
            cell.cancelButton.isHidden = true
        } else {
            cell.checkButton.isHidden = false
            cell.cancelButton.isHidden = false
        }
        cell.controller = self
        cell.layoutCell(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if need != "BlockUsers" {
            if let userProfilePage = UIStoryboard.profile.instantiateViewController(
                withIdentifier: ProfileVC.reuseIdentifier) as? ProfileVC {
                userProfilePage.otherUserID = requests[indexPath.row].userID
                self.navigationController?.pushViewController(userProfilePage, animated: true)
            }
        } else {
            let alert = UIAlertController(
                title: "確定解除對\(requests[indexPath.row].userSelfID)的封鎖？",
                message: nil,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { [weak self] _ in
                guard let self = self else { return }
                FirebaseManager.shared.changeBlock(blockID: self.requests[indexPath.row].userID) {
                    print("成功解除封鎖")
                    self.fetchRequest()
                }
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            alert.addAction(action)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
    }
}
