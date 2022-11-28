//
//  WaterRecordProvider.swift
//  DietRecord
//
//  Created by chun on 2022/11/3.
//

import Foundation

typealias WaterDailyResult = (Result<Any, Error>) -> Void
typealias UpdateWaterResult = (Result<Void, Error>) -> Void

class WaterRecordProvider {
    // MARK: - Fetch water record -
    func fetchWaterRecord(completion: @escaping WaterDailyResult) {
        let date = DRConstant.dateFormatter.string(from: Date())
        let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).collection(DRConstant.water).document(date)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    let waterRecordData = try? document.data(as: WaterRecord.self)
                else {
                    do {
                        let waterRecord = WaterRecord(water: "0", date: date)
                        try documentReference.setData(from: waterRecord)
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                    return
                }
                completion(.success(waterRecordData))
            }
        }
    }
    // MARK: - Update water record -
    func updateWaterRecord(totalWater: String, completion: @escaping UpdateWaterResult) {
        let date = DRConstant.dateFormatter.string(from: Date())
        let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).collection(DRConstant.water).document(date)
        let waterRecord = WaterRecord(water: totalWater, date: date)
        do {
            try documentReference.setData(from: waterRecord)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    // MARK: - Fetch history water record -
    func fetchHistoryWaterRecords(completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        var waterRecords: [WaterRecord] = []
        DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).collection(DRConstant.water).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                var documents = snapshot.documents
                documents = documents.sorted { $0.documentID < $1.documentID }
                for document in documents {
                    guard let waterRecord = try? document.data(as: WaterRecord.self) else { return }
                    waterRecords.append(waterRecord)
                }
                completion(.success(waterRecords))
            }
        }
    }
    // MARK: - Update water goal -
    func updateWaterGoal(waterGoal: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var userData = try? document.data(as: User.self)
                else { return }
                userData.waterGoal = waterGoal
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
