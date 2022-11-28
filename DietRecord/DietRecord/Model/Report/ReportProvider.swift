//
//  ReportProvider.swift
//  DietRecord
//
//  Created by chun on 2022/11/9.
//

import Foundation


class ReportProvider {
    // MARK: - Fetch Diet Weekly Record -
    func fetchWeeklyDietRecord(date: Date, completion: @escaping FoodDailyResult) {
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
                let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).collection(DRConstant.diet).document(date)
                documentReference.getDocument { document, error in
                    if let error = error {
                        completion(.failure(error))
                        downloadGroup.leave()
                    } else {
                        guard let document = document,
                            document.exists,
                            let dietRecordData = try? document.data(as: FoodDailyInput.self)
                        else {
                            downloadGroup.leave()
                            return }
                        weeklyDietRecord.append(dietRecordData)
                        downloadGroup.leave()
                    }
                }
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion(.success(weeklyDietRecord))
        }
    }
    
    func changeGoal(goal: [String], completion: @escaping (Result<Void, Error>) -> Void ) {
        DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var userData = try? document.data(as: User.self)
                else { return }
                userData.goal = goal
                do {
                    try DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).setData(from: userData)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
