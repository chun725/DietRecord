//
//  FirebaseManager+Profile.swift
//  DietRecord
//
//  Created by chun on 2022/12/8.
//

import Foundation

typealias DietRecordHistoryResult = ([FoodDailyInput]) -> Void
typealias MealRecordsResult = ([MealRecord]) -> Void
typealias UserDataResult = (User?) -> Void
typealias UserDatasResult = ([User]) -> Void
typealias UserSelfIDIsUsed = (Bool) -> Void

extension FirebaseManager {
    // Fetch the images of the diet records
    func fetchImage(userID: String, completion: @escaping DietRecordHistoryResult) {
        let collectionReference = FSCollectionEndpoint.dietRecord(userID).collectionRef
        self.getDocuments(collectionReference) { (dietRecords: [FoodDailyInput]) in
            let sortedDietRecords = dietRecords.sorted { $0.mealRecord[0].date < $1.mealRecord[0].date }
            completion(sortedDietRecords)
        }
    }
    
    // Fetch the posts of the following users' diet records
    func fetchFollowingPost(completion: @escaping MealRecordsResult) {
        var mealRecords: [MealRecord] = []
        self.fetchUserData(userID: DRConstant.userID) { userData in
            guard let userData = userData else { return }
            var followings = userData.following
            followings.append(userData.userID)
            let downloadGroup = DispatchGroup()
            var blocks: [DispatchWorkItem] = []
            for following in followings {
                downloadGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    let collectionReference = FSCollectionEndpoint.dietRecord(following).collectionRef
                    self.getDocuments(collectionReference) { (dietRecords: [FoodDailyInput]?) in
                        guard let dietRecords = dietRecords
                        else {
                            completion(mealRecords)
                            downloadGroup.leave()
                            return
                        }
                        dietRecords.forEach { dietRecord in
                            let mealRecordsData = dietRecord.mealRecord.filter { $0.isShared }
                            mealRecords.append(contentsOf: mealRecordsData)
                        }
                        downloadGroup.leave()
                    }
                }
                blocks.append(block)
                DispatchQueue.main.async(execute: block)
            }
            downloadGroup.notify(queue: DispatchQueue.main) {
                completion(mealRecords)
            }
        }
    }
    
    // Change the likes of the meal record
    func changeLiked(authorID: String, date: String, meal: Int, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.dietRecord(authorID, date).documentRef
        self.getDocument(documentReference) { (dietRecord: FoodDailyInput?) in
            guard var dietRecord = dietRecord,
                var mealRecord = dietRecord.mealRecord.first(where: { $0.meal == meal })
            else { return }
            if mealRecord.peopleLiked.contains(DRConstant.userID) {
                mealRecord.peopleLiked.removeAll { $0 == DRConstant.userID }
            } else {
                mealRecord.peopleLiked.append(DRConstant.userID)
            }
            dietRecord.mealRecord.removeAll { $0.meal == meal }
            dietRecord.mealRecord.append(mealRecord)
            self.setData(dietRecord, at: documentReference)
            completion()
        }
    }
    
    // Post the response in the profile detail page
    func postResponse(postUserID: String, date: String, meal: Int, response: String, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.dietRecord(postUserID, date).documentRef
        self.getDocument(documentReference) { (dietRecord: FoodDailyInput?) in
            guard var dietRecord = dietRecord,
                var mealRecord = dietRecord.mealRecord.first(where: { $0.meal == meal })
            else { return }
            let response = Response(person: DRConstant.userID, response: response)
            mealRecord.response.append(response)
            dietRecord.mealRecord.removeAll { $0.meal == meal }
            dietRecord.mealRecord.append(mealRecord)
            self.setData(dietRecord, at: documentReference)
            completion()
        }
    }
    
    // Fetch the user data
    func fetchUserData(userID: String, completion: @escaping UserDataResult) {
        let documentReference = FSDocumentEndpoint.userData(userID).documentRef
        self.getDocument(documentReference) { (userData: User?) in
            completion(userData)
        }
    }
    
    // 更改交友邀請
    func changeRequest(isRequest: Bool, followID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: followID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            if isRequest {
                userData.request.removeAll { $0 == DRConstant.userID }
            } else if !userData.blocks.contains(DRConstant.userID) && !userData.request.contains(DRConstant.userID) {
                userData.request.append(DRConstant.userID)
            }
            self.setData(userData, at: FSDocumentEndpoint.userData(followID).documentRef)
            completion()
        }
    }
    
    // 更改他人追蹤狀態
    func changeFollow(isFollowing: Bool, followID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: followID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            if isFollowing {
                userData.followers.removeAll { $0 == DRConstant.userID }
            } else if !userData.following.contains(DRConstant.userID) {
                userData.following.append(DRConstant.userID)
            }
            self.setData(userData, at: FSDocumentEndpoint.userData(followID).documentRef)
            self.changeSelfFollow(isFollowing: isFollowing, followID: followID) {
                completion()
            }
        }
    }
    
    // 更改自身追蹤狀態
    private func changeSelfFollow(isFollowing: Bool, followID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: DRConstant.userID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            if isFollowing {
                userData.following.removeAll { $0 == followID }
            } else if !userData.followers.contains(followID) {
                userData.followers.append(followID)
                userData.request.removeAll { $0 == followID }
            }
            self.setData(userData, at: FSDocumentEndpoint.userData(DRConstant.userID).documentRef)
            completion()
        }
    }
    
    // 獲取多個user的資料
    func fetchUsersData(userID: String, need: String, completion: @escaping UserDatasResult) {
        self.fetchUserData(userID: userID) { [weak self] userData in
            guard let self = self,
                let userData = userData
            else { return }
            var users: [User] = []
            let downloadGroup = DispatchGroup()
            var blocks: [DispatchWorkItem] = []
            var usersID: [String] = []
            switch need {
            case "Followers":
                usersID = userData.followers
            case "Following":
                usersID = userData.following
            case "BlockUsers":
                usersID = userData.blocks
            default:
                usersID = userData.request
            }
            for followerID in usersID {
                downloadGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    self.fetchUserData(userID: followerID) { user in
                        guard let user = user
                        else {
                            downloadGroup.leave()
                            return
                        }
                        users.append(user)
                        downloadGroup.leave()
                    }
                }
                blocks.append(block)
                DispatchQueue.main.async(execute: block)
            }
            downloadGroup.notify(queue: DispatchQueue.main) {
                completion(users)
            }
        }
    }
    
    // 取消交友邀請
    func cancelRequest(followID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: DRConstant.userID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            userData.request.removeAll { $0 == followID }
            self.setData(userData, at: FSDocumentEndpoint.userData(DRConstant.userID).documentRef)
            completion()
        }
    }
    
    // 新增用戶資料
    func createUserInfo(userData: User, completion: @escaping () -> Void) {
        self.setData(userData, at: FSDocumentEndpoint.userData(userData.userID).documentRef)
        completion()
    }
    
    // 看user自行設定的ID是否有重複
    func fetchUserSelfID(selfID: String, completion: @escaping UserSelfIDIsUsed) {
        let collectionReference = FSCollectionEndpoint.user.collectionRef
        self.getDocuments(collectionReference.whereField("userSelfID", isEqualTo: selfID)) { (userDatas: [User]) in
            completion(userDatas.isEmpty)
        }
    }
    
    // 透過userSelfID去搜尋user資料
    func searchUser(userSelfID: String, completion: @escaping UserDataResult) {
        let collectionReference = FSCollectionEndpoint.user.collectionRef
        self.getDocuments(collectionReference.whereField("userSelfID", isEqualTo: userSelfID)) { (userDatas: [User]?) in
            completion(userDatas?.first)
        }
    }
    
    // 檢舉用戶 or 貼文 or 回覆
    func reportSomething(user: User?, mealRecord: MealRecord?, response: Response?, completion: @escaping () -> Void) {
        let uuid = UUID().uuidString
        let documentReference = FSDocumentEndpoint.report(uuid).documentRef
        if let user = user {
            self.setData(user, at: documentReference)
        } else if let mealRecord = mealRecord {
            self.setData(mealRecord, at: documentReference)
        } else if let response = response {
            self.setData(response, at: documentReference)
        }
        completion()
    }
    
    // 刪除貼文 or 回覆
    func deletePostOrResponse(mealRecord: MealRecord, response: Response?, completion: @escaping () -> Void) {
        let documentReference = FSDocumentEndpoint.dietRecord(mealRecord.userID, mealRecord.date).documentRef
        self.getDocument(documentReference) { [weak self] (dietRecord: FoodDailyInput?) in
            guard let self = self,
                var dietRecord = dietRecord,
                var newMealRecord = dietRecord.mealRecord.first(where: { $0.meal == mealRecord.meal })
            else { return }
            if response != nil {
                guard let response = response,
                    let index = newMealRecord.response.firstIndex(of: response)
                else { return }
                newMealRecord.response.remove(at: index)
            } else {
                newMealRecord.isShared = false
            }
            dietRecord.mealRecord.removeAll { $0.meal == mealRecord.meal }
            dietRecord.mealRecord.append(newMealRecord)
            self.setData(dietRecord, at: documentReference)
            completion()
        }
    }
    
    // 更改封鎖狀態
    func changeBlock(blockID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: DRConstant.userID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            if userData.blocks.contains(blockID) {
                userData.blocks.removeAll { $0 == blockID }
                self.setData(userData, at: FSDocumentEndpoint.userData(DRConstant.userID).documentRef)
                completion()
            } else {
                userData.blocks.append(blockID)
                self.setData(userData, at: FSDocumentEndpoint.userData(DRConstant.userID).documentRef)
                self.changeBothBlock(userOneID: DRConstant.userID, userTwoID: blockID) {
                    self.changeBothBlock(userOneID: blockID, userTwoID: DRConstant.userID) {
                        completion()
                    }
                }
            }
        }
    }
    
    // 封鎖時要將雙方的follower及following都清掉
    func changeBothBlock(userOneID: String, userTwoID: String, completion: @escaping () -> Void) {
        self.fetchUserData(userID: userOneID) { [weak self] userData in
            guard let self = self,
                var userData = userData
            else { return }
            userData.following.removeAll { $0 == userTwoID }
            userData.followers.removeAll { $0 == userTwoID }
            self.setData(userData, at: FSDocumentEndpoint.userData(userOneID).documentRef)
            completion()
        }
    }
    
    // 刪除帳戶
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        let collectionReferences = [
            FSCollectionEndpoint.water.collectionRef,
            FSCollectionEndpoint.weight.collectionRef,
            FSCollectionEndpoint.dietRecord(DRConstant.userID).collectionRef
        ]
        for collectionReference in collectionReferences {
            deleteGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                collectionReference.getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot
                        else {
                            deleteGroup.leave()
                            return }
                        snapshot.documents.forEach { document in
                            collectionReference.document(document.documentID).delete()
                        }
                        deleteGroup.leave()
                    }
                }
            }
            if collectionReference == collectionReferences.last {
                deleteGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    let documentReference = FSDocumentEndpoint.userData(DRConstant.userID).documentRef
                    documentReference.delete()
                    self.revokeToken()
                    deleteGroup.leave()
                }
                blocks.append(block)
                DispatchQueue.main.async(execute: block)
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        deleteGroup.notify(queue: DispatchQueue.main) {
            completion(.success(()))
        }
    }
    
    private func revokeToken() {
        let refreshToken = KeyChainManager.shared.getToken()
        guard let clientSecret = GenerateJWT.shared.fetchClientSecret(),
            let url = URL(string: "https://appleid.apple.com/auth/revoke?client_id=com.Chun.DietRecord&client_secret=\(clientSecret)&token=\(refreshToken)&token_type_hint=refresh_token")
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                print("======error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode
            else {
                print("=======statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            print("=========\(response.statusCode)")
        }
        task.resume()
    }
    
    // 移除所有追蹤
    func removeFollow(allUsers: [String], completion: @escaping () -> Void) {
        let deleteGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        for otherUserID in allUsers {
            deleteGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                self.fetchUserData(userID: otherUserID) { [weak self] userData in
                    guard let self = self,
                        var userData = userData
                    else { return }
                    userData.following.removeAll { $0 == DRConstant.userID }
                    userData.followers.removeAll { $0 == DRConstant.userID }
                    self.setData(userData, at: FSDocumentEndpoint.userData(otherUserID).documentRef)
                }
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        deleteGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}
