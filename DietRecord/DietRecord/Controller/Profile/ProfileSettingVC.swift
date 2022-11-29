//
//  ProfileSettingVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit

class ProfileSettingVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var userSelfIDLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        userSelfIDLabel.text = DRConstant.userData?.userSelfID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingTableView.reloadData()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
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
