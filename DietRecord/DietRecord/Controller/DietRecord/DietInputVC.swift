//
//  DietInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class DietInputVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodDairyTableView: UITableView!
    
    var foods: [Food] = [] {
        didSet {
            foodDairyTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodDairyTableView.dataSource = self
        foodDairyTableView.register(
            UINib(nibName: FoodDairyCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: FoodDairyCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func goToFoodSearchPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let foodSearchPage = storyboard.instantiateViewController(withIdentifier: "\(FoodSearchVC.self)")
            as? FoodSearchVC {
            foodSearchPage.closure = { [weak self] foods in
                self?.foods = foods
            }
            self.navigationController?.pushViewController(foodSearchPage, animated: false)
        }
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
        cell.layoutCell(foods: foods)
        cell.editFoodButton.addTarget(self, action: #selector(goToFoodSearchPage), for: .touchUpInside)
        return cell
    }
}
