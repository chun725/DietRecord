//
//  HealthKitManager.swift
//  Part3
//
//  Created by chun on 2022/10/27.
//

import HealthKit
import CoreMedia

class HealthKitManager {
    let healthKitStore = HKHealthStore()
    
    // 能不能取得HealthKit權限
    func authorizeHealthKit(completion: ((_ success: Bool, _ error: NSError?) -> Void)?) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }
        
        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead: Set<HKObjectType> = Set(arrayLiteral: quantityType)
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite: Set<HKSampleType> = Set(arrayLiteral: quantityType)
        
        // 以防萬一使用iPad
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        healthKitStore.requestAuthorization(
            toShare: healthDataToWrite,
            read: healthDataToRead) { success, error -> Void in
                guard let completion = completion else { return }
                completion(success, error  as NSError?)
        }
    }
    
    // 是否已經向用戶詢問健康App的權限
    func haveGetPermission(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }

        // State the health data type(s) we want to read from HealthKit.
        let healthDataToRead: Set<HKObjectType> = Set(arrayLiteral: quantityType)
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite: Set<HKSampleType> = Set(arrayLiteral: quantityType)

        healthKitStore.getRequestStatusForAuthorization(
            toShare: healthDataToWrite,
            read: healthDataToRead) { success, error -> Void in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(success.rawValue))
            }
        }
    }
    
    // 是否有權限可以寫入資料至健康App中
    func havePermissionOfWrite(completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }
        let index = healthKitStore.authorizationStatus(for: quantityType).rawValue
        if index == 2 {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // 得到健康App中的體重記錄
    func getWeight(sampleType: HKSampleType, completion: (([HKSample]?, NSError?) -> Void)?) {
        // Predicate for the weight query
        let distantPastWeight = NSDate.distantPast as NSDate
        let currentDate = NSDate()
        let weightPredicate = HKQuery.predicateForSamples(
            withStart: distantPastWeight as Date,
            end: currentDate as Date,
            options: .strictEndDate)

        // Get the single most recent weight
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let weightQuery = HKSampleQuery(
            sampleType: sampleType,
            predicate: weightPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { _, results, error -> Void in
                if let queryError = error, let completion = completion {
                    completion(nil, queryError as NSError)
                    return
                }
                if let completion = completion {
                    completion(results, nil)
                }
        }

        // Time to execute the query.
        self.healthKitStore.execute(weightQuery)
    }
    
    // 新增體重記錄至健康App中
    func saveWeight(weightData: WeightData, completion: @escaping ((Result<Void, NSError>) -> Void)) {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }
        
        let weightQuanity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightData.value)
        let weight = HKQuantitySample(
            type: bodyMassType,
            quantity: weightQuanity,
            start: weightData.date,
            end: weightData.date)
        healthKitStore.save(weight) { _, error -> Void in
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // 刪除健康App中的體重記錄
    func deleteWeight(weightData: WeightData, completion: @escaping ((Result<Void, Error>) -> Void)) {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }
   
        let distantPastWeight = NSDate.distantPast as NSDate
        let currentDate = Date()
        let weightPredicate = HKQuery.predicateForSamples(
            withStart: distantPastWeight as Date,
            end: currentDate,
            options: .strictEndDate)
        // Get the single most recent weight
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let weightQuery = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: weightPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { _, results, error -> Void in
                if let error = error {
                    completion(.failure(error))
                }
                if let results = results, let weight = results.first(where: { $0.startDate == weightData.date }) {
                    self.healthKitStore.delete(weight) { _, _ -> Void in
                        completion(.success(()))
                    }
                }
        }
        self.healthKitStore.execute(weightQuery)
    }
}
