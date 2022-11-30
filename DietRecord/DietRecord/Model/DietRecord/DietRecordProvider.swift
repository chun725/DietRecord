//
//  FoodProvider.swift
//  DietRecord
//
//  Created by chun on 2022/10/31.
//

import FirebaseStorage

typealias FoodSearchResults = (Result<[FoodIngredient], Error>) -> Void
typealias UploadImageURL = (Result<URL, Error>) -> Void
typealias CreateFoodDailyResult = (Result<Void, Error>) -> Void
typealias FoodDailyResult = (Result<Any, Error>) -> Void

class DietRecordProvider {
    // MARK: - Search food in database -
    func searchFoods(foodName: String, completion: @escaping FoodSearchResults) {
        guard let foodIngredients = DRConstant.foodIngredients
        else { fatalError("Could not find food ingredient database.") }
        let foods: [FoodIngredient] = foodIngredients.filter { foodIngredient in
            if foodIngredient.commonName.contains(foodName) || foodIngredient.name.contains(foodName) {
                return true
            } else {
                return false
            }
        }
        completion(Result.success(foods))
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
    func createFoodDaily(date: String, mealRecord: MealRecord, completion: @escaping CreateFoodDailyResult) {
        let documentReference = DRConstant.database
            .collection(DRConstant.user)
            .document(DRConstant.userID)
            .collection(DRConstant.diet)
            .document(date)
        documentReference.getDocument { document, error in
            guard let document = document,
                document.exists,
                var data = try? document.data(as: FoodDailyInput.self)
            else {
                do {
                    try documentReference.setData(from: FoodDailyInput(mealRecord: [mealRecord]))
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
                return
            }
            let index = data.mealRecord.firstIndex { $0.meal == mealRecord.meal }
            if let index = index {
                data.mealRecord.remove(at: index)
            }
            data.mealRecord.append(mealRecord)
            do {
                try documentReference.setData(from: data)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Diet Daily Record -
    func fetchDietRecord(date: String, completion: @escaping FoodDailyResult) {
        DRConstant.database
            .collection(DRConstant.user)
            .document(DRConstant.userID)
            .collection(DRConstant.diet)
            .document(date)
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let document = document,
                        document.exists,
                        let dietRecordData = try? document.data(as: FoodDailyInput.self)
                    else {
                        completion(.success("Document doesn't exist."))
                        return
                    }
                    completion(.success(dietRecordData))
                }
            }
    }
}
