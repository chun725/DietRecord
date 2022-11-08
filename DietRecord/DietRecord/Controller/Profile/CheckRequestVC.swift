//
//  CheckReqestVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/8.
//

import UIKit

class CheckRequestVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var requestTableView: UITableView!
    
    var requests: [User] = [] {
        didSet {
            requestTableView.reloadData()
        }
    }
    
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTableView.dataSource = self
        fetchRequest()
    }
    
    func fetchRequest() {
        profileProvider.fetchRequest { result in
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
        cell.controller = self
        cell.layoutCell(user: user)
        return cell
    }
}
