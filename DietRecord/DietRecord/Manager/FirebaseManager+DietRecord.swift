//
//  FirebaseManager+DietRecord.swift
//  DietRecord
//
//  Created by chun on 2022/12/7.
//

import Foundation
import FirebaseStorage
import UIKit

typealias FoodSearchResults = ([FoodIngredient]) -> Void
typealias UploadImageURL = (Result<URL, Error>) -> Void
typealias DietRecordDailyResult = (FoodDailyInput?) -> Void

extension FirebaseManager {
    // MARK: - Search food in database -
    func searchFoods(foodName: String, completion: @escaping FoodSearchResults) {
        guard let foodIngredients = DRConstant.foodIngredients
        else { fatalError("Could not find food ingredient database.") }
        let foods: [FoodIngredient] = foodIngredients.filter { foodIngredient in
            return foodIngredient.commonName.contains(foodName) || foodIngredient.name.contains(foodName)
        }
        completion(foods)
    }
    
    // MARK: - Upload image -
    func uploadImage(image: UIImage, completion: @escaping UploadImageURL ) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.1) {
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
    
    // MARK: - Add food daily record -
    func createFoodDaily(date: String, mealRecord: MealRecord, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.dietRecord(DRConstant.userID, date).documentRef
        self.getDocument(documentReference) { (foodDailyInput: FoodDailyInput?) in
            guard var foodDailyInput = foodDailyInput
            else {
                self.setData(FoodDailyInput(mealRecord: [mealRecord]), at: documentReference)
                completion()
                return
            }

            if let index = foodDailyInput.mealRecord.firstIndex(where: { $0.meal == mealRecord.meal }) {
                foodDailyInput.mealRecord.remove(at: index)
            }
            
            foodDailyInput.mealRecord.append(mealRecord)
            self.setData(foodDailyInput, at: documentReference)
            completion()
        }
    }
    
    // MARK: - Fetch Diet Daily Record -
    func fetchDietRecord(date: String, completion: @escaping DietRecordDailyResult) {
        let documentReference = FSDocumentEndpoint.dietRecord(DRConstant.userID, date).documentRef
        self.getDocument(documentReference) { (dietRecord: FoodDailyInput?) in
            completion(dietRecord)
        }
    }
}
