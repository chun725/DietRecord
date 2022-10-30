//
//  ViewController.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class DietRecordVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var dietRecordTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dietRecordTableView.dataSource = self
        dietRecordTableView.register(UINib(nibName: CaloriesPieChartCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: CaloriesPieChartCell.reuseIdentifier)
        dietRecordTableView.register(UINib(nibName: DietRecordCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DietRecordCell.reuseIdentifier)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CaloriesPieChartCell.reuseIdentifier, for: indexPath) as? CaloriesPieChartCell else { fatalError("Could not create calories pie chart cell.") }
            cell.layoutCell(calories: "1500/2100 kcal", carbs: "47.5/89.4 g", protein: "47.5/89.4 g", fat: "47.5/89.4 g")
            cell.setPieChart(breakfast: 340, lunch: 590, dinner: 890, others: 120, goal: 2100)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DietRecordCell.reuseIdentifier, for: indexPath) as? DietRecordCell else { fatalError("Could not create calories pie chart cell.") }
            cell.layoutCell(foods: ["dk kd", "sfvgf"], photo: " ", comment: "哈哈哈哈")
            return cell
        }
    }


}

