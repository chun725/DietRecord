//
//  ProfileProvider.swift
//  DietRecord
//
//  Created by chun on 2022/11/5.
//

import Foundation

class ProfileProvider {
    func fetchImage(userID: String, completion: @escaping (Result<[FoodDailyInput], Error>) -> Void) {
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
            followings.append(userData.userID)
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
    
    func changeLiked(authorID: String, date: String, meal: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(authorID).collection(diet).document(date)
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
    
    func postResponse(postUserID: String, date: String, meal: Int, response: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(postUserID).collection(diet).document(date)
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
    
    func fetchUserData(userID: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.collection(user).document(userID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document else { return }
                if document.exists, let user = try? document.data(as: User.self) {
                    completion(.success(user))
                } else {
                    completion(.success("document不存在"))
                }
            }
        }
    }
    
    func changeRequest(isRequest: Bool, followID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(followID)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                if isRequest {
                    user.request.removeAll { $0 == userID }
                } else {
                    user.request.append(userID)
                }
                do {
                    try documentReference.setData(from: user)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func changeFollow(isFollowing: Bool, followID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let followDocumentRef = database.collection(user).document(followID)
        followDocumentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                if isFollowing {
                    user.followers.removeAll { $0 == userID }
                } else {
                    user.following.append(userID)
                }
                do {
                    try followDocumentRef.setData(from: user)
                    self.changeSelf(isFollowing: isFollowing, followID: followID) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func changeSelf(isFollowing: Bool, followID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let selfDocumentRef = database.collection(user).document(userID)
        selfDocumentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                if isFollowing {
                    user.following.removeAll { $0 == followID }
                } else {
                    user.followers.append(followID)
                    user.request.removeAll { $0 == followID }
                }
                do {
                    try selfDocumentRef.setData(from: user)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUsersData(userID: String, need: String, completion: @escaping (Result<[User], Error>) -> Void) {
        let documentRef = database.collection(user).document(userID)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    let userData = try? document.data(as: User.self)
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
                default:
                    usersID = userData.request
                }
                for followerID in usersID {
                    downloadGroup.enter()
                    let block = DispatchWorkItem(flags: .inheritQoS) {
                        database.collection(user).document(followerID).getDocument { document, error in
                            if let error = error {
                                completion(.failure(error))
                                downloadGroup.leave()
                            } else {
                                guard let document = document,
                                    document.exists,
                                    let user = try? document.data(as: User.self)
                                else { return }
                                users.append(user)
                                downloadGroup.leave()
                            }
                        }
                    }
                    blocks.append(block)
                    DispatchQueue.main.async(execute: block)
                }
                downloadGroup.notify(queue: DispatchQueue.main) {
                    completion(.success(users))
                }
            }
        }
    }
}

extension ProfileProvider {
    func cancelRequest(followID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(userID)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                user.request.removeAll { $0 == followID }
                do {
                    try documentReference.setData(from: user)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createUserInfo(userData: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentReference = database.collection(user).document(userData.userID)
        documentReference.getDocument { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    try documentReference.setData(from: userData)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUserSelfID(selfID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.collection(user).whereField("userSelfID", isEqualTo: selfID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                if snapshot.documents.isEmpty {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    func searchUser(userSelfID: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.collection(user).whereField("userSelfID", isEqualTo: userSelfID).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                if snapshot.documents.isEmpty {
                    completion(.success("document不存在"))
                } else {
                    guard let document = snapshot.documents.first,
                        let user = try? document.data(as: User.self)
                    else { return }
                    completion(.success(user))
                }
            }
        }
    }
    
    func reportSomething(user: User?, mealRecord: MealRecord?, response: Response?, completion: @escaping (Result<Void, Error>) -> Void) {
        let uuid = UUID().uuidString
        let documentReference = database.collection(report).document(uuid)
        do {
            if let user = user {
                try documentReference.setData(from: user)
            } else if let mealRecord = mealRecord {
                try documentReference.setData(from: mealRecord)
            } else if let response = response {
                try documentReference.setData(from: response)
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deletePostOrResponse(mealRecord: MealRecord, response: Response?, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = mealRecord.userID
        let documentRef = database.collection(user).document(id).collection(diet).document(mealRecord.date)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    var olderMealRecords = try? document.data(as: FoodDailyInput.self).mealRecord
                else { return }
                for olderMealRecord in olderMealRecords where olderMealRecord.meal == mealRecord.meal {
                    var newMealRecord = olderMealRecord
                    olderMealRecords.remove(at: olderMealRecords.firstIndex(of: olderMealRecord) ?? 0)
                    if response != nil {
                        guard let response = response,
                            let index = newMealRecord.response.firstIndex(of: response)
                        else { return }
                        newMealRecord.response.remove(at: index)
                    } else {
                        newMealRecord.isShared = false
                    }
                    olderMealRecords.append(newMealRecord)
                }
                do {
                    let data = FoodDailyInput(mealRecord: olderMealRecords)
                    try documentRef.setData(from: data)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
