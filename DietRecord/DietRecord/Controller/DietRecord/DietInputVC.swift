//
//  DietInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class DietInputVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodDairyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodDairyTableView.dataSource = self
        foodDairyTableView.register(
            UINib(nibName: FoodDairyCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: FoodDairyCell.reuseIdentifier)
    }
    
    @IBAction func goBackToDietRecordPage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodDairyCell.reuseIdentifier,
            for: indexPath) as? FoodDairyCell
        else { fatalError("Could not create food dairy cell.") }
        cell.layoutCell(foods: ["jsdc", "sanjkk", "djikx"])
        return cell
    }
}
