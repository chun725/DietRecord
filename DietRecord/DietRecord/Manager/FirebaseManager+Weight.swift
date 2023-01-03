//
//  FirebaseManager+Weight.swift
//  DietRecord
//
//  Created by chun on 2022/12/7.
//

import Foundation

typealias WeightRecordResult = ([WeightData]) -> Void

extension FirebaseManager {
    // 將健康App裡的體重記錄更新到Firestore裡
    func updateWeightRecord(weightDatas: [WeightData], completion: @escaping () -> Void ) {
        let updateGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []

        for weightData in weightDatas {
            updateGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                let dateString = DRConstant.dateFormatter.string(from: weightData.date)
                let documentReference = FSDocumentEndpoint.weight(dateString).documentRef
                self.getDocument(documentReference) { (weightRecord: WeightData?) in
                    guard weightRecord != nil
                    else {
                        self.setData(weightData, at: documentReference)
                        updateGroup.leave()
                        return
                    }
                    updateGroup.leave()
                }
            }
            blocks.append(block)
            DispatchQueue.global().async(execute: block)
        }
        updateGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    // 取得體重記錄
    func fetchWeightRecord(sync: Bool, completion: @escaping WeightRecordResult) {
        let collectionReference = FSCollectionEndpoint.weight.collectionRef
        self.getDocuments(collectionReference) { (weightDatas: [WeightData]?) in
            guard var weightDatas = weightDatas else { return }
            if !sync {
                weightDatas = weightDatas.filter { $0.dataSource == WeightDataSource.dietRecord.rawValue }
            }
            completion(weightDatas)
        }
    }
    
    // 新增體重記錄
    func createWeightRecord(weightData: WeightData, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionReference = FSCollectionEndpoint.weight.collectionRef
        let dateString = DRConstant.dateFormatter.string(from: weightData.date)
        self.setData(weightData, at: collectionReference.document(dateString))
        self.healthManager.havePermissionOfWrite { [weak self] result in
            guard let self = self else { return }
            if result {
                self.healthManager.saveWeight(weightData: weightData) { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 刪除體重記錄
    func deleteWeightRecord(weightData: WeightData, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionReference = FSCollectionEndpoint.weight.collectionRef
        let dateString = DRConstant.dateFormatter.string(from: weightData.date)
        self.delete(collectionReference.document(dateString))
        self.healthManager.havePermissionOfWrite { [weak self] result in
            guard let self = self else { return }
            if result {
                self.healthManager.deleteWeight(weightData: weightData) { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        print(error)
                        completion(.success(()))
                    }
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 更新體重目標
    func updateWeightGoal(weightGoal: String, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.userData(DRConstant.userID).documentRef
        self.getDocument(documentReference) { [weak self] (userData: User?) in
            guard let self = self,
                var userData = userData
            else { return }
            userData.weightGoal = weightGoal
            self.setData(userData, at: documentReference)
            completion()
        }
    }
}
