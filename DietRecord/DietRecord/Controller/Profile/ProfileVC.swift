//
//  ProfileVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var mealRecords: [MealRecord] = [] {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    
    var fullScreenSize = UIScreen.main.bounds.size
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.collectionViewLayout = configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDietRecord()
    }
    
    func fetchDietRecord() {
        profileProvider.fetchImage { result in
            switch result {
            case .success(let dietRecords):
                var mealDatas: [MealRecord] = []
                for dietRecord in dietRecords {
                    let mealRecords = dietRecord.mealRecord.sorted { $0.meal < $1.meal }
                    for mealRecord in mealRecords {
                        mealDatas.append(mealRecord)
                    }
                }
                self.mealRecords = mealDatas.reversed()
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    // MARK: - CollectionViewDataSource -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mealRecords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCell.reuseIdentifier, for: indexPath) as? ProfileCell
        else { fatalError("Could not create the profile cell.") }
        let mealRecord = mealRecords[indexPath.row]
        cell.layoutCell(imageURL: mealRecord.imageURL)
        return cell
    }
    
    // MARK: - CollectionViewDelegate -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mealRecord = mealRecords[indexPath.row]
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let profileDetailPage = storyboard.instantiateViewController(withIdentifier: "\(ProfileDetailVC.self)")
            as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            self.present(profileDetailPage, animated: false)
        }
    }
}


extension ProfileVC: UICollectionViewDelegateFlowLayout {
    // MARK: - DelegateFlowLayout -
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: CGFloat(fullScreenSize.width / 3), height: CGFloat(fullScreenSize.width) / 3)
        return size
    }
    
    // MARK: - FlowLayout -
    func configureLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
}
