//
//  WaterHistoryVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/11.
//

import UIKit

class WaterHistoryVC: UIViewController {
    @IBOutlet weak var waterHistoryBarChart: UIView!
    
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LKProgressHUD.show()
        fetchWaterRecord()
    }
    
    func fetchWaterRecord() {
        waterRecordProvider.fetchHistoryWaterRecords { result in
            switch result {
            case .success(let waterRecords):
                LKProgressHUD.dismiss()
                let barChart = BarChart(frame: .zero, superview: self.waterHistoryBarChart)
                barChart.setWaterBarChart(waterRecords: waterRecords)
            case .failure(let error):
                LKProgressHUD.showFailure(text: "無法讀取飲水量記錄")
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
