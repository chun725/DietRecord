//
//  ProfileSettingVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit

class ProfileSettingVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var userSelfIDLabel: UILabel! {
        didSet {
            userSelfIDLabel.text = DRConstant.userData?.userSelfID
        }
    }
    @IBOutlet weak var settingTableView: UITableView! {
        didSet {
            settingTableView.dataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        settingTableView.reloadData()
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileSettingCell.reuseIdentifier, for: indexPath) as? ProfileSettingCell
        else { fatalError("Create the profile setting cell.") }
        cell.controller = self
        cell.layoutCell()
        return cell
    }
}
