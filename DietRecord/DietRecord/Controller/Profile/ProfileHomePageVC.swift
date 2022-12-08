//
//  ProfileHomePageVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/12.
//

import UIKit

class ProfileHomePageVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var homeTableView: UITableView!
    
    var refreshControl: UIRefreshControl?
    var followingPosts: [MealRecord] = [] {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.dataSource = self
        homeTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        homeTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchFollowingPost), for: .valueChanged)
        fetchFollowingPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func fetchFollowingPost() {
        self.refreshControl?.beginRefreshing()
        FirebaseManager.shared.fetchFollowingPost { [weak self] mealRecords in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            self.followingPosts = mealRecords.sorted { $0.createdTime > $1.createdTime }.filter { $0.isShared }
        }
    }
    
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
