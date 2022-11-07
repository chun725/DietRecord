//
//  ProfileProvider.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import Foundation

class ProfileProvider {
    func fetchImage(completion: @escaping (Result<[FoodDailyInput], Error>) -> Void) {
        var dietRecords: [FoodDailyInput] = []
        database.collection(user).document(userID).collection(diet).order(by: "date").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                let documents = snapshot.documents
                for document in documents {
                    guard let dietRecord = try? document.data(as: FoodDailyInput.self) else { return }
                    dietRecords.append(dietRecord)
                }
                completion(.success(dietRecords))
            }
        }
    }
    
    func changeLiked(userID: String, date: String, meal: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(userID).collection(diet).document(date)
        documentReference.getDocument { document, error in
            guard let document = document,
                document.exists,
                var dietRecord = try? document.data(as: FoodDailyInput.self)
            else { return }
            var mealRecords = dietRecord.mealRecord
            guard var mealRecord = mealRecords.first(where: { $0.meal == meal }) else { return }
            if mealRecord.peopleLiked.contains(userID) {
                mealRecord.peopleLiked.removeAll { $0 == userID }
            } else {
                mealRecord.peopleLiked.append(userID)
            }
            mealRecords.removeAll { $0.meal == meal }
            mealRecords.append(mealRecord)
            dietRecord.mealRecord = mealRecords
            do {
                try documentReference.setData(from: dietRecord)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func postResponse(userID: String, date: String, meal: Int, response: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(userID).collection(diet).document(date)
        documentReference.getDocument { document, error in
            guard let document = document,
                document.exists,
                var dietRecord = try? document.data(as: FoodDailyInput.self)
            else { return }
            var mealRecords = dietRecord.mealRecord
            guard var mealRecord = mealRecords.first(where: { $0.meal == meal }) else { return }
            let response = Response(person: userID, response: response)
            mealRecord.response.append(response)
            mealRecords.removeAll { $0.meal == meal }
            mealRecords.append(mealRecord)
            dietRecord.mealRecord = mealRecords
            do {
                try documentReference.setData(from: dietRecord)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
