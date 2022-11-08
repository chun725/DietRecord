//
//  ProfileVC.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class ProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    var selfMealRecords: [MealRecord] = [] {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    
    var followingPosts: [MealRecord] = [] {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    var fullScreenSize = UIScreen.main.bounds.size
    let profileProvider = ProfileProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.collectionViewLayout = configureLayout()
        homeTableView.dataSource = self
        homeTableView.registerCellWithNib(identifier: ProfileDetailCell.reuseIdentifier, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFollowingPost()
        fetchSelfDietRecord()
    }
    
    func fetchSelfDietRecord() {
        profileProvider.fetchImage { result in
            switch result {
            case .success(let dietRecords):
                var mealDatas: [MealRecord] = []
                for dietRecord in dietRecords {
                    let mealRecords = dietRecord.mealRecord.sorted { $0.meal < $1.meal }
                    mealDatas.append(contentsOf: mealRecords)
                }
                self.selfMealRecords = mealDatas.reversed()
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    func fetchFollowingPost() {
        profileProvider.fetchFollowingPost { result in
            switch result {
            case .success(let mealRecords):
                self.followingPosts = mealRecords.sorted { $0.createdTime > $1.createdTime }
            case .failure(let error):
                print("Error Info: \(error).")
            }
        }
    }
    
    @IBAction func changePage(sender: UIButton) {
        if sender == homeButton {
            self.photoCollectionView.isHidden = true
            self.homeTableView.isHidden = false
        } else {
            self.photoCollectionView.isHidden = false
            self.homeTableView.isHidden = true
        }
    }
    
    @IBAction func goToCheckRequestPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let checkRequestPage = storyboard.instantiateViewController(withIdentifier: "\(CheckRequestVC.self)")
            as? CheckRequestVC {
            self.navigationController?.pushViewController(checkRequestPage, animated: false)
        }
    }
    
    @IBAction func goToAddFollowingPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let addFollowingPage = storyboard.instantiateViewController(withIdentifier: "\(AddFollowingVC.self)")
            as? AddFollowingVC {
            self.navigationController?.pushViewController(addFollowingPage, animated: false)
        }
    }
    
    // MARK: - CollectionViewDataSource -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selfMealRecords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCell.reuseIdentifier, for: indexPath) as? ProfileCell
        else { fatalError("Could not create the profile cell.") }
        let mealRecord = selfMealRecords[indexPath.row]
        cell.layoutCell(imageURL: mealRecord.imageURL)
        return cell
    }
    
    // MARK: - CollectionViewDelegate -
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mealRecord = selfMealRecords[indexPath.row]
        let storyboard = UIStoryboard(name: profile, bundle: nil)
        if let profileDetailPage = storyboard.instantiateViewController(withIdentifier: "\(ProfileDetailVC.self)")
            as? ProfileDetailVC {
            profileDetailPage.mealRecord = mealRecord
            self.navigationController?.pushViewController(profileDetailPage, animated: false)
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

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        followingPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileDetailCell.reuseIdentifier, for: indexPath) as? ProfileDetailCell
        else { fatalError("Could not create the profile detail cell.") }
        let mealRecord = self.followingPosts[indexPath.row]
        cell.haveResponses = false
        cell.controller = self
        cell.layoutCell(mealRecord: mealRecord)
        return cell
    }
}
