//
//  HealthKitManager.swift
//  Part3
//
//  Created by chun on 2022/10/27.
//

import HealthKit

class HealthKitManager {
    let healthKitStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((_ success: Bool, _ error: NSError?) -> Void)?) { // 能不能取得HealthKit權限
        
        // State the health data type(s) we want to read from HealthKit.
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        else { return }
        
        let healthDataToRead: Set<HKObjectType> = Set(_immutableCocoaSet: quantityType)
        // let healthDataToRead = Set(arrayLiteral: quantityType)
        // State the health data type(s) we want to write from HealthKit.
        let healthDataToWrite: Set<HKSampleType> = Set(_immutableCocoaSet: quantityType)
        // let healthDataToWrite = Set(arrayLiteral: quantityType)
        // 以防萬一使用iPad
        if !HKHealthStore.isHealthDataAvailable() {
            print("Can't access HealthKit.")
        }
        
        // Request authorization to read and/or write the specific data.
        healthKitStore.requestAuthorization(
            toShare: healthDataToWrite,
            read: healthDataToRead) { success, error -> Void in
                guard let completion = completion else { return }
                completion(success, error  as NSError?)
        }
    }
    
    func getWeight(sampleType: HKSampleType, completion: (([HKSample]?, NSError?) -> Void)?) {
        // Predicate for the weight query
        let distantPastWeight = NSDate.distantPast as NSDate
        let currentDate = NSDate()
        let lastWeightPredicate = HKQuery.predicateForSamples(
            withStart: distantPastWeight as Date,
            end: currentDate as Date,
            options: .strictEndDate)

        // Get the single most recent weight
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // Query HealthKit for the last Height entry.
        let weightQuery = HKSampleQuery(
            sampleType: sampleType,
            predicate: lastWeightPredicate,
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
}
