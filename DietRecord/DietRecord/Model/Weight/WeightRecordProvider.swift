//
//  WeightRecordProvider.swift
//  DietRecord
//
//  Created by chun on 2022/11/4.
//

import Foundation

typealias WeightRecordResult = (Result<[WeightData], Error>) -> Void

class WeightRecordProvider {
    let healthManager = HealthKitManager()
    // MARK: - Update weight record from Health to firebase -
    func updateWeightRecord(weightDatas: [WeightData], completion: @escaping (Result<Void, Error>) -> Void) {
        let updateGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for weightData in weightDatas {
            updateGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                let collectionReference = DRConstant.database
                    .collection(DRConstant.user)
                    .document(DRConstant.userID)
                    .collection(DRConstant.weight)
                collectionReference.getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot else { return }
                        if snapshot.documents.isEmpty {
                            do {
                                let dateString = DRConstant.dateFormatter.string(from: weightData.date)
                                try collectionReference.document(dateString).setData(from: weightData)
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }
                    updateGroup.leave()
                }
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        updateGroup.notify(queue: DispatchQueue.main) {
            completion(.success(()))
        }
    }
    
    func fetchWeightRecord(sync: Bool, completion: @escaping WeightRecordResult) {
        let collectionReference = DRConstant.database
            .collection(DRConstant.user)
            .document(DRConstant.userID)
            .collection(DRConstant.weight)
        collectionReference.getDocuments { snapshot, error in
            if let error = error {
                print("Error Info: \(error).")
            } else {
                var weightDatas: [WeightData] = []
                guard let snapshot = snapshot else { return }
                let documents = snapshot.documents
                for document in documents {
                    guard let weightData = try? document.data(as: WeightData.self) else { return }
                    if sync {
                        weightDatas.append(weightData)
                    } else {
                        if weightData.dataSource == WeightDataSource.dietRecord.rawValue {
                            weightDatas.append(weightData)
                        }
                    }
                }
                completion(.success(weightDatas))
            }
        }
    }
    
    func createWeightRecord(weightData: WeightData, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionReference = DRConstant.database
            .collection(DRConstant.user)
            .document(DRConstant.userID)
            .collection(DRConstant.weight)
        do {
            let dateString = DRConstant.dateFormatter.string(from: weightData.date)
            guard let date = DRConstant.dateFormatter.date(from: dateString) else { return }
            try collectionReference.document(dateString).setData(from: WeightData(
                date: date, value: weightData.value, dataSource: weightData.dataSource))
            healthManager.havePermissionOfWrite { [weak self] result in
                if result {
                    self?.healthManager.saveWeight(
                        weightData:
                            WeightData(
                                date: date,
                                value: weightData.value,
                                dataSource: weightData.dataSource)) { result in
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
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteWeightRecord(weightData: WeightData, completion: @escaping (Result<Void, Error>) -> Void) {
        let collectionReference = DRConstant.database
            .collection(DRConstant.user)
            .document(DRConstant.userID)
            .collection(DRConstant.weight)
        let dateString = DRConstant.dateFormatter.string(from: weightData.date)
        collectionReference.document(dateString).delete()
        healthManager.havePermissionOfWrite { [weak self] result in
            if result {
                self?.healthManager.deleteWeight(weightData: weightData) { result in
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
    
    func updateWeightGoal(weightGoal: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var userData = try? document.data(as: User.self)
                else { return }
                userData.weightGoal = weightGoal
                do {
                    try documentReference.setData(from: userData)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
