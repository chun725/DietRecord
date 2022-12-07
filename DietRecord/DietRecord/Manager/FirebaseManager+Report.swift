//
//  FirebaseManager+Report.swift
//  DietRecord
//
//  Created by chun on 2022/12/7.
//

import Foundation

typealias DietRecordWeeklyResult = ([FoodDailyInput]) -> Void

extension FirebaseManager {
    func fetchWeeklyDietRecord(date: Date, completion: @escaping DietRecordWeeklyResult) {
        var dates: [String] = []
        for index in 0..<7 {
            let lastDate = date.advanced(by: -60 * 60 * 24 * Double(index))
            dates.append(DRConstant.dateFormatter.string(from: lastDate))
        }
        var weeklyDietRecord: [FoodDailyInput] = []
        let downloadGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        for date in dates {
            downloadGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                let documentReference = FSDocumentEndpoint.dietRecord(DRConstant.userID, date).documentRef
                self.getDocument(documentReference) { (dietRecord: FoodDailyInput?) in
                    guard let dietRecord = dietRecord
                    else {
                        downloadGroup.leave()
                        return
                    }
                    weeklyDietRecord.append(dietRecord)
                    downloadGroup.leave()
                }
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion(weeklyDietRecord)
        }
    }
    
    func changeGoal(goal: [String], completion: @escaping () -> Void ) {
        let documentReference = FSDocumentEndpoint.userData(DRConstant.userID).documentRef
        self.getDocument(documentReference) { [weak self] (userData: User?) in
            guard let self = self,
                var userData = userData
            else { return }
            userData.goal = goal
            self.setData(userData, at: documentReference)
            completion()
        }
    }
}
