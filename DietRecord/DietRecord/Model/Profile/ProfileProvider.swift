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
}
