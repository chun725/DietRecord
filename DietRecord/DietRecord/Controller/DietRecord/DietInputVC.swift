//
//  DietInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit
import PhotosUI
import FirebaseFirestore

class DietInputVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodDailyTableView: UITableView! {
        didSet {
            foodDailyTableView.dataSource = self
            foodDailyTableView.registerCellWithNib(identifier: FoodDailyCell.reuseIdentifier, bundle: nil)
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 20
        }
    }
    
    private var foods: [Food] = [] {
        didSet {
            foodDailyTableView.reloadData()
        }
    }
    private var mealTextField: UITextField?
    private var mealImageView: UIImageView?
    private var dateTextField: UITextField?
    private var commentTextView: UITextView?
    private var imageURL: String?
    var closure: ((String) -> Void)?
    var isShared = true
    var mealRecord: MealRecord?
    var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mealRecord = mealRecord {
            foods = mealRecord.foods
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Action -
    @objc func goToFoodSearchPage(sender: UIButton) {
        if let foodSearchPage = UIStoryboard.dietRecord.instantiateViewController(
            withIdentifier: FoodSearchVC.reuseIdentifier) as? FoodSearchVC {
            foodSearchPage.oldfoods = foods
            foodSearchPage.closure = { [weak self] foods in
                self?.foods = foods
            }
            hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(foodSearchPage, animated: true)
        }
    }
    
    @objc func chooseMeal(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "選擇餐類", preferredStyle: .actionSheet)
        for mealString in Meal.allCases.map({ $0.rawValue }) where mealString != "差異" {
            let action = UIAlertAction(title: mealString, style: .default) { _ in
                self.mealTextField?.text = mealString
            }
            optionMenu.addAction(action)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(cancel)
        self.present(optionMenu, animated: true)
    }
    
    @objc func choosePhotoSource(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "選擇照片來源", preferredStyle: .actionSheet)
        let photoGallery = UIAlertAction(title: "照片圖庫", style: .default) { _ in
            self.selectPhoto()
        }
        let camera = UIAlertAction(title: "相機", style: .default) { _ in
            self.takeCamera()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(photoGallery)
        optionMenu.addAction(camera)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true)
    }
    
    func uploadImage() {
        saveButton.isEnabled = false
        guard let image = self.mealImageView?.image else { return }
        FirebaseManager.shared.uploadImage(image: image) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let url):
                self.imageURL = url.absoluteString
                self.saveButton.isEnabled = true
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func saveFoodDaily() {
        guard let date = dateTextField?.text,
            let meal = mealTextField?.text,
            let comment = commentTextView?.text
        else { return }
        if date.isEmpty {
            self.presentInputAlert(title: "請選擇日期")
        } else if meal.isEmpty {
            self.presentInputAlert(title: "請選擇餐類")
        } else if foods.isEmpty {
            self.presentInputAlert(title: "請輸入飲食紀錄")
        } else if imageURL == nil && isShared {
            self.presentInputAlert(title: "若要分享到個人頁面，需新增相片")
        } else {
            DRProgressHUD.show()
            guard let index = Meal.allCases.map({ $0.rawValue }).firstIndex(of: meal) else { return }
            
            let mealRecord = MealRecord(
                userID: DRConstant.userID,
                meal: index,
                date: date,
                foods: foods,
                imageURL: imageURL,
                comment: comment,
                isShared: self.isShared,
                createdTime: Date(),
                peopleLiked: [],
                response: [])
            
            FirebaseManager.shared.createFoodDaily(date: date, mealRecord: mealRecord) {
                DRProgressHUD.showSuccess(text: "儲存成功")
                self.closure?(date)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - TableViewDataSource -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoodDailyCell.reuseIdentifier,
            for: indexPath) as? FoodDailyCell
        else { fatalError("Could not create food daily cell.") }
        if let mealRecord = mealRecord {
            cell.mealRecord = mealRecord
        } else {
            cell.dateTextField.text = self.date
        }
        cell.controller = self
        cell.layoutCell(foods: foods)
        cell.editFoodButton.addTarget(self, action: #selector(goToFoodSearchPage), for: .touchUpInside)
        cell.mealChooseButton.addTarget(self, action: #selector(chooseMeal), for: .touchUpInside)
        cell.changePhotoButton.addTarget(self, action: #selector(choosePhotoSource), for: .touchUpInside)
        mealTextField = cell.mealTextField
        mealImageView = cell.mealImageView
        commentTextView = cell.commentTextView
        dateTextField = cell.dateTextField
        return cell
    }
}

extension DietInputVC: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - 從相簿上傳照片 -
    func selectPhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = self.mealImageView?.image
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] image, _ in
                DispatchQueue.main.async {
                    guard let self = self,
                        let image = image as? UIImage,
                        let mealImageView = self.mealImageView,
                        mealImageView.image == previousImage else { return }
                    mealImageView.image = image
                    self.uploadImage()
                }
            }
        }
    }
    
    // MARK: - 透過相機上傳照片 -
    func takeCamera() {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.allowsEditing = true
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.mealImageView?.image = pickedImage
            self.uploadImage()
        }
        picker.dismiss(animated: true)
    }
}
