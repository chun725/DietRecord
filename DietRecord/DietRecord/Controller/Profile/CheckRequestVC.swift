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
    
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTableView.dataSource = self
        requestTableView.delegate = self
        fetchRequest()
        if need == "Followers" {
            titleLabel.text = "Followers"
        } else if need == "Following" {
            titleLabel.text = "Following"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func fetchRequest() {
        var id = userID
        if let otherUserID = otherUserID {
            id = otherUserID
        }
        profileProvider.fetchUsersData(userID: id, need: need) { result in
            switch result {
            case .success(let users):
                self.requests = users
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
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
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let userProfilePage = storyboard.instantiateViewController(withIdentifier: "\(ProfileVC.self)")
            as? ProfileVC {
            userProfilePage.otherUserID = requests[indexPath.row].userID
            self.navigationController?.pushViewController(userProfilePage, animated: false)
        }
    }
}
