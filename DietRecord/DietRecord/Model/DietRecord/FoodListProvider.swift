//
//  FoodProvider.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import Foundation

typealias FoodSearchResults = (Result<[FoodIngredient]>) -> Void

class FoodListProvider {
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
}
