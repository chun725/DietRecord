//
//  DietInputVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import UIKit
import PhotosUI

class DietInputVC: UIViewController, UITableViewDataSource {
    @IBOutlet weak var foodDairyTableView: UITableView!
    
    var foods: [Food] = [] {
        didSet {
            foodDairyTableView.reloadData()
        }
    }
    let dietRecordProvider = DietRecordProvider()
    var mealTextField: UITextField?
    var mealImageView: UIImageView?
    var datePicker: UIDatePicker?
    var choosePhoto: UIImage?
    var commentTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodDairyTableView.dataSource = self
        foodDairyTableView.registerCellWithNib(identifier: FoodDairyCell.reuseIdentifier, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Action -
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
    
    @objc func chooseMeal(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "選擇餐類", preferredStyle: .actionSheet)
        let breakfast = UIAlertAction(title: Meal.breakfast.rawValue, style: .default) { _ in
            self.mealTextField?.text = Meal.breakfast.rawValue
        }
        let lunch = UIAlertAction(title: Meal.lunch.rawValue, style: .default) { _ in
            self.mealTextField?.text = Meal.lunch.rawValue
        }
        let dinner = UIAlertAction(title: Meal.dinner.rawValue, style: .default) { _ in
            self.mealTextField?.text = Meal.dinner.rawValue
        }
        let others = UIAlertAction(title: Meal.others.rawValue, style: .default) { _ in
            self.mealTextField?.text = Meal.others.rawValue
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        optionMenu.addAction(breakfast)
        optionMenu.addAction(lunch)
        optionMenu.addAction(dinner)
        optionMenu.addAction(others)
        optionMenu.addAction(cancel)
        self.present(optionMenu, animated: false)
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
        self.present(optionMenu, animated: false)
    }
    
    @IBAction func goBackToDietRecordPage(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        guard let image = self.mealImageView?.image else { return }
        dietRecordProvider.uploadImage(image: image) { result in
            switch result {
            case .success(let url):
                self.saveFoodDairy(imageURL: url.absoluteString)
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    func saveFoodDairy(imageURL: String) {
        guard let date = datePicker?.date,
            let meal = mealTextField?.text,
            let comment = commentTextView?.text
        else { return }
        let mealRecord = MealRecord(meal: meal, foods: foods, imageURL: imageURL, comment: comment)
        dietRecordProvider.createFoodDairy(
            date: dateFormatter.string(from: date),
            mealRecord: mealRecord) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: false)
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    // MARK: - TableViewDataSource -
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
        cell.mealChooseButton.addTarget(self, action: #selector(chooseMeal), for: .touchUpInside)
        cell.changePhotoButton.addTarget(self, action: #selector(choosePhotoSource), for: .touchUpInside)
        mealTextField = cell.mealTextField
        mealImageView = cell.mealImageView
        datePicker = cell.datePicker
        commentTextView = cell.commentTextView
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
        present(picker, animated: false)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: false)
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
                    self.choosePhoto = image
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
        self.present(controller, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.mealImageView?.image = pickedImage
            self.choosePhoto = pickedImage
        }
        picker.dismiss(animated: false)
    }
}