//
//  WaterHistoryVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/11.
//

import UIKit
import Lottie

class WaterHistoryVC: UIViewController {
    @IBOutlet weak var swipeLottieView: LottieAnimationView!
    @IBOutlet weak var waterHistoryBarChart: UIView!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var barChartBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHistoryWaterRecord()
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 0.8
        lottieView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func fetchHistoryWaterRecord() {
        DRProgressHUD.show()
        FirebaseManager.shared.fetchHistoryWaterRecords { [weak self] waterRecords in
            guard let self = self else { return }
            DRProgressHUD.dismiss()
            let barChart = BarChart(frame: .zero, superview: self.waterHistoryBarChart)
            barChart.setWaterBarChart(waterRecords: waterRecords)
            if waterRecords.count > 7 {
                self.swipeLottieView.isHidden = false
                self.swipeLottieView.animationSpeed = 2
                self.swipeLottieView.loopMode = .repeat(2)
                self.swipeLottieView.play { _ in
                    self.swipeLottieView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
