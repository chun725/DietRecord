//
//  FoodSearchVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit

class FoodSearchVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodInputTextField: UITextField!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func goToFoodNutritionPage(sender: UIButton) {
        let storyboard = UIStoryboard(name: dietRecord, bundle: nil)
        if let foodNutritionPage = storyboard.instantiateViewController(withIdentifier: "\(FoodNutritionVC.self)")
            as? FoodNutritionVC {
            self.navigationController?.pushViewController(foodNutritionPage, animated: false)
        }
    }
    
    @IBAction func goBackToDietInputPage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodSearchResultCell.reuseidentifier,
            for: indexPath) as? FoodSearchResultCell
        else { fatalError("Could not create food search result cell.") }
        cell.layoutCell(food: "edcwj")
        cell.detailButton.addTarget(self, action: #selector(goToFoodNutritionPage), for: .touchUpInside)
        cell.backgroundColor = .clear
        return cell
    }
}
