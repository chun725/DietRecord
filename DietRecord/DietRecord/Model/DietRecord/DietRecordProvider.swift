//
//  FoodProvider.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import FirebaseStorage
import UIKit

typealias FoodSearchResults = (Result<[FoodIngredient], Error>) -> Void

class DietRecordProvider {
    let decoder = JSONDecoder()
    
    func fetchFoods(foodName: String, completion: @escaping FoodSearchResults) {
        database.collection(foodIngredient).getDocuments { snapshot, error in
            if let error = error {
                completion(Result.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                let documents = snapshot.documents
                let foods: [FoodIngredient] = documents.compactMap { document in
                    guard let food = try? document.data(as: FoodIngredient.self)
                    else { fatalError("Could not find food.") }
                    if food.commonName.contains(foodName) || food.name.contains(foodName) {
                        return food
                    } else {
                        return nil
                    }
                }
                completion(Result.success(foods))
            }
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            fileReference.putData(uploadData) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
//    func createFoodDairy(date: String, foodDairyInput: FoodDairyInput, completion: @escaping (Result<Void, Error>) -> Void) {
//        do {
//            try database.collection(user).document(userID).collection(diet).document(date).setData(from: foodDairyInput)
//            completion(.success(()))
//        } catch {
//            completion(.failure(error))
//        }
//    }
}
