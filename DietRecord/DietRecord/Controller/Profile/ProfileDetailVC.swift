//
//  ProfileDetailVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileDetailVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var profileDetailTableView: UITableView!
    @IBOutlet weak var responseTextView: UITextView!
    
    var mealRecord: MealRecord?
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileDetailTableView.dataSource = self
    }
    
    @IBAction func goBackProfilePage(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func createResponse(_ sender: Any) {
        guard let mealRecord = mealRecord else { return }
        profileProvider.postResponse(
            userID: userID,
            date: mealRecord.date,
            meal: mealRecord.meal,
            response: responseTextView.text) { result in
            switch result {
            case .success:
                self.mealRecord?.response.append(Response(person: userID, response: self.responseTextView.text))
                self.profileDetailTableView.reloadData()
                self.responseTextView.text = ""
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mealRecord = mealRecord else {
            return section == 0 ? 1 : 0
        }
        return section == 0 ? 1 : mealRecord.response.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileDetailCell.reuseIdentifier, for: indexPath) as? ProfileDetailCell,
                let mealRecord = mealRecord
            else { fatalError("Could not create the profile detail cell.") }
            cell.layoutCell(username: "0000", userImage: "eeee", mealRecord: mealRecord)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileResponseCell.reuseIdentifier, for: indexPath) as? ProfileResponseCell,
                let mealRecord = mealRecord
            else { fatalError("Could not create the profile detail cell.") }
            let response = mealRecord.response[indexPath.row]
            cell.layoutCell(response: response)
            return cell
        }
    }
}
