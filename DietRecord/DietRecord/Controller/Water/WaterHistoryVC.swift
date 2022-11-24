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
    
    let waterRecordProvider = WaterRecordProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LKProgressHUD.show()
        fetchWaterRecord()
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 0.8
        lottieView.play()
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRect(x: barChartBackgroundView.bounds.width / 2 - 130, y: barChartBackgroundView.bounds.height / 2 - 130, width: 260, height: 260)
//        gradientLayer.type = .radial
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.8)
//        gradientLayer.colors = [UIColor.drLightYellow.cgColor, UIColor.drLightGray.cgColor]
//        barChartBackgroundView.layer.addSublayer(gradientLayer)
//        barChartBackgroundView.clipsToBounds = true
    }
    
    func fetchWaterRecord() {
        waterRecordProvider.fetchHistoryWaterRecords { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let waterRecords):
                LKProgressHUD.dismiss()
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
