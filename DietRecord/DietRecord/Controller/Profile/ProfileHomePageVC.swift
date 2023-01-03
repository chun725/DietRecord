//
//  ProfileHomePageVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/12.
//

import UIKit

class ProfileHomePageVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var homeTableView: UITableView! {
        didSet {
            homeTableView.dataSource = self
            homeTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
            homeTableView.addSubview(refreshControl)
        }
    }
    
    var userDatas: [String: User] = [:]
    private var refreshControl = UIRefreshControl()
    private var followingPosts: [MealRecord] = [] {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFollowingPost()
        refreshControl.addTarget(self, action: #selector(fetchFollowingPost), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func fetchFollowingPost() {
        self.refreshControl.beginRefreshing()
        FirebaseManager.shared.fetchFollowingPost { [weak self] mealRecords, userDatas in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.userDatas = userDatas
            if self.followingPosts != mealRecords {
                self.followingPosts = mealRecords
            }
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        followingPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileDetailCell.reuseIdentifier, for: indexPath) as? ProfileDetailCell
        else { fatalError("Could not create the profile detail cell.") }
        let mealRecord = self.followingPosts[indexPath.row]
        cell.haveResponses = false
        cell.controller = self
        cell.layoutCell(mealRecord: mealRecord, nowUserData: nil)
        return cell
    }
}
