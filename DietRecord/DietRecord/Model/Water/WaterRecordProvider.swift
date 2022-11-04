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
        let date = dateFormatter.string(from: Date())
        let documentReference = database.collection(user).document(userID).collection(water).document(date)
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
        let date = dateFormatter.string(from: Date())
        let documentReference = database.collection(user).document(userID).collection(water).document(date)
        let waterRecord = WaterRecord(water: totalWater, date: date)
        do {
            try documentReference.setData(from: waterRecord)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
