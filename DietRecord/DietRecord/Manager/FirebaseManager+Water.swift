//
//  FirebaseManager+Water.swift
//  DietRecord
//
//  Created by chun on 2022/12/7.
//

import Foundation

typealias WaterDailyResult = (WaterRecord) -> Void
typealias WaterHistoryResult = ([WaterRecord]) -> Void

extension FirebaseManager {
    // 取得飲水量記錄
    func fetchWaterRecord(completion: @escaping WaterDailyResult) {
        let date = DRConstant.dateFormatter.string(from: Date())
        let documentReference = FSDocumentEndpoint.water(date).documentRef
        self.getDocument(documentReference) { (waterRecord: WaterRecord?) in
            guard let waterRecord = waterRecord
            else {
                let waterRecord = WaterRecord(water: "0", date: date)
                self.setData(waterRecord, at: documentReference)
                completion(waterRecord)
                return
            }
            completion(waterRecord)
        }
    }
    
    // 更新飲水量記錄
    func updateWaterRecord(totalWater: String, completion: @escaping () -> Void) {
        let date = DRConstant.dateFormatter.string(from: Date())
        let documentReference = FSDocumentEndpoint.water(date).documentRef
        let waterRecord = WaterRecord(water: totalWater, date: date)
        self.setData(waterRecord, at: documentReference)
        completion()
    }
    
    // 取得飲水量歷史記錄
    func fetchHistoryWaterRecords(completion: @escaping WaterHistoryResult) {
        let collectionReference = FSCollectionEndpoint.water.collectionRef
        self.getDocuments(collectionReference) { (waterRecords: [WaterRecord]?) in
            guard var waterRecords = waterRecords else { return }
            waterRecords = waterRecords.sorted { $0.date < $1.date }
            completion(waterRecords)
        }
    }
    
    // 更新飲水目標
    func updateWaterGoal(waterGoal: String, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.userData(DRConstant.userID).documentRef
        self.getDocument(documentReference) { (userData: User?) in
            guard var userData = userData else { return }
            userData.waterGoal = waterGoal
            self.setData(userData, at: documentReference)
            completion()
        }
    }
}
