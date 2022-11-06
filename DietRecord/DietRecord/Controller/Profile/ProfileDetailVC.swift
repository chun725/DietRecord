//
//  ProfileDetailVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import UIKit

class ProfileDetailVC: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var mealRecord: MealRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.loadImage(mealRecord?.imageURL, placeHolder: UIImage(named: "Image_Placeholder"))
        commentLabel.text = mealRecord?.comment
    }
    
    @IBAction func goBackProfilePage(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
