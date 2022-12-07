//
//  ProfileInformationCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/15.
//

import UIKit
import PhotosUI

class ProfileInformationCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var userSelfIDTextfield: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var waterGoalTextField: UITextField!
    @IBOutlet weak var weightGoalTextField: UITextField!
    @IBOutlet weak var inputButton: UIButton!
    @IBOutlet weak var automaticButton: UIButton!
    @IBOutlet weak var dietView: UIView!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var waterView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var dietGoalCollectionView: UICollectionView! {
        didSet {
            dietGoalCollectionView.dataSource = self
            dietGoalCollectionView.delegate = self
            dietGoalCollectionView.collectionViewLayout = configureLayout()
        }
    }
    
    let profileProvider = ProfileProvider()
    var imageURL = DRConstant.placeholderURL {
        didSet {
            user.userImageURL = imageURL
        }
    }
    
    var goal: [String] = [] {
        didSet {
            dietGoalCollectionView.reloadData()
            user.goal = goal
        }
    }
    
    var user = User(
        userID: DRConstant.userID,
        userSelfID: "",
        following: [],
        followers: [],
        blocks: [],
        request: [],
        userImageURL: DRConstant.placeholderURL,
        username: "",
        goal: [],
        waterGoal: "",
        weightGoal: "") {
            didSet {
                controller?.user = user
            }
        }
    
    weak var controller: ProfileInformationVC?
    
    func layoutCell() {
        inputButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
        automaticButton.addTarget(self, action: #selector(goToSetupGoalVC), for: .touchUpInside)
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        changeImageButton.layer.cornerRadius = changeImageButton.bounds.width / 2
        let views = [idView, nameView, waterView, weightView, dietView]
        for view in views {
            view?.setBorder(width: 1, color: .drGray, radius: 15)
        }
        waterGoalTextField.delegate = self
        weightGoalTextField.delegate = self
        usernameTextField.delegate = self
        userSelfIDTextfield.delegate = self
        changeImageButton.addTarget(self, action: #selector(choosePhotoSource), for: .touchUpInside)
        inputButton.layer.cornerRadius = 10
        automaticButton.layer.cornerRadius = 10
        if let controller = controller, controller.isUpdated {
            userImageView.loadImage(user.userImageURL)
            usernameTextField.text = user.username
            waterGoalTextField.text = user.waterGoal.transform(unit: Units.mLUnit.rawValue)
            weightGoalTextField.text = user.weightGoal.transform(unit: Units.kgUnit.rawValue)
            userSelfIDTextfield.text = user.userSelfID
        } else {
            controller?.user = user
        }
    }
    
    func uploadImage() {
        controller?.saveButton.isEnabled = false
        guard let image = self.userImageView.image else { return }
        FirebaseManager.shared.uploadImage(image: image) { result in
            switch result {
            case .success(let url):
                self.imageURL = url.absoluteString
                print(url.absoluteString)
                self.controller?.saveButton.isEnabled = true
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @objc func goToSetupGoalVC(sender: UIButton) {
        let storyboard = UIStoryboard(name: DRConstant.report, bundle: nil)
        if let setupGoalPage = storyboard.instantiateViewController(withIdentifier: "\(SetupGoalVC.self)")
            as? SetupGoalVC {
            if sender == inputButton {
                setupGoalPage.isAutomatic = false
            }
            setupGoalPage.closure = { [weak self] goal in
                self?.goal = goal
            }
            controller?.navigationController?.pushViewController(setupGoalPage, animated: true)
        }
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
        controller?.present(optionMenu, animated: true)
    }
}

extension ProfileInformationCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DietGoalCollectionViewCell.reuseIdentifier,
            for: indexPath) as? DietGoalCollectionViewCell
        else { fatalError("Could not create the diet goal collection view cell.") }
        let row = indexPath.row
        if goal.isEmpty {
            cell.layoutCell(row: row, goal: "-")
        } else {
            cell.layoutCell(row: row, goal: goal[row])
        }
        return cell
    }
    
    func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        return layout
    }
}

extension ProfileInformationCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == waterGoalTextField && textField.text?.isEmpty == false {
            user.waterGoal = textField.text ?? ""
            textField.text = textField.text?.transform(unit: Units.mLUnit.rawValue)
        } else if textField == weightGoalTextField && textField.text?.isEmpty == false {
            user.weightGoal = textField.text ?? ""
            textField.text = textField.text?.transform(unit: Units.kgUnit.rawValue)
        } else if textField == usernameTextField {
            user.username = textField.text ?? ""
        } else if textField == userSelfIDTextfield {
            if textField.text == "" {
                self.controller?.presentInputAlert(title: "用戶名不能為空")
                self.infoImageView.isHidden = false
                self.checkImageView.isHidden = true
            } else if textField.text == DRConstant.userData?.userSelfID {
                print("使用舊用戶名")
                self.checkImageView.isHidden = false
                self.infoImageView.isHidden = true
            } else {
                DRProgressHUD.show()
                profileProvider.fetchUserSelfID(selfID: textField.text ?? "") { result in
                    DRProgressHUD.dismiss()
                    switch result {
                    case .success(let success):
                        if success {
                            self.user.userSelfID = textField.text ?? ""
                            self.infoImageView.isHidden = true
                            self.checkImageView.isHidden = false
                        } else {
                            self.user.userSelfID = ""
                            self.controller?.presentInputAlert(title: "此用戶名稱已被人使用")
                            self.infoImageView.isHidden = false
                            self.checkImageView.isHidden = true
                        }
                    case .failure(let error):
                        print("Error Info: \(error).")
                    }
                }
            }
        }
    }
}

extension ProfileInformationCell:
    PHPickerViewControllerDelegate,
    UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
    // MARK: - 從相簿上傳照片 -
    func selectPhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        controller?.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = self.userImageView.image
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] image, _ in
                DispatchQueue.main.async {
                    guard let self = self,
                        let image = image as? UIImage,
                        let userImageView = self.userImageView,
                        userImageView.image == previousImage else { return }
                    userImageView.image = image
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
        self.controller?.present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.userImageView.image = pickedImage
            self.uploadImage()
        }
        picker.dismiss(animated: true)
    }
}
