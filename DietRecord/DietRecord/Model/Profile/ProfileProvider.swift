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
        database.collection(user).document(userID).collection(diet).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                var documents = snapshot.documents
                documents = documents.sorted { $0.documentID < $1.documentID }
                for document in documents {
                    guard let dietRecord = try? document.data(as: FoodDailyInput.self) else { return }
                    dietRecords.append(dietRecord)
                }
                completion(.success(dietRecords))
            }
        }
    }
    
    func fetchFollowingPost(completion: @escaping (Result<[MealRecord], Error>) -> Void) {
        var mealRecords: [MealRecord] = []
        database.collection(user).document(userID).getDocument { document, error in
            guard let document = document,
                document.exists,
                let userData = try? document.data(as: User.self)
            else { return }
            var followings = userData.following
            followings.append(userData.user)
            let downloadGroup = DispatchGroup()
            var blocks: [DispatchWorkItem] = []
            for following in followings {
                downloadGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    database.collection(user).document(following).collection(diet).getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            downloadGroup.leave()
                        } else {
                            guard let snapshot = snapshot else { return }
                            let documents = snapshot.documents
                            for document in documents {
                                guard let dietRecord = try? document.data(as: FoodDailyInput.self) else { return }
                                let mealRecordsData = dietRecord.mealRecord.filter { $0.isShared == true }
                                mealRecords.append(contentsOf: mealRecordsData)
                            }
                            downloadGroup.leave()
                        }
                    }
                }
                blocks.append(block)
                DispatchQueue.main.async(execute: block)
            }
            downloadGroup.notify(queue: DispatchQueue.main) {
                completion(.success(mealRecords))
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
