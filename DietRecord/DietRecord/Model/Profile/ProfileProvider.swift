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
        DRConstant.database
            .collection(DRConstant.user)
            .document(userID)
            .collection(DRConstant.diet)
            .getDocuments { snapshot, error in
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
        DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).getDocument { document, error in
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
                    DRConstant.database
                        .collection(DRConstant.user)
                        .document(following)
                        .collection(DRConstant.diet)
                        .getDocuments { snapshot, error in
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
        let documentReference = DRConstant.database
            .collection(DRConstant.user)
            .document(authorID)
            .collection(DRConstant.diet)
            .document(date)
        documentReference.getDocument { document, error in
            guard let document = document,
                document.exists,
                var dietRecord = try? document.data(as: FoodDailyInput.self)
            else { return }
            var mealRecords = dietRecord.mealRecord
            guard var mealRecord = mealRecords.first(where: { $0.meal == meal }) else { return }
            if mealRecord.peopleLiked.contains(DRConstant.userID) {
                mealRecord.peopleLiked.removeAll { $0 == DRConstant.userID }
            } else {
                mealRecord.peopleLiked.append(DRConstant.userID)
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
        let documentReference = DRConstant.database
            .collection(DRConstant.user)
            .document(postUserID)
            .collection(DRConstant.diet)
            .document(date)
        documentReference.getDocument { document, error in
            guard let document = document,
                document.exists,
                var dietRecord = try? document.data(as: FoodDailyInput.self)
            else { return }
            var mealRecords = dietRecord.mealRecord
            guard var mealRecord = mealRecords.first(where: { $0.meal == meal }) else { return }
            let response = Response(person: DRConstant.userID, response: response)
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
        DRConstant.database.collection(DRConstant.user).document(userID).getDocument { document, error in
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
        let documentReference = DRConstant.database.collection(DRConstant.user).document(followID)
        documentReference.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                if isRequest {
                    user.request.removeAll { $0 == DRConstant.userID }
                } else if !user.blocks.contains(DRConstant.userID) && !user.request.contains(DRConstant.userID) {
                    user.request.append(DRConstant.userID)
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
        let followDocumentRef = DRConstant.database.collection(DRConstant.user).document(followID)
        followDocumentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    var user = try? document.data(as: User.self)
                else { return }
                if isFollowing {
                    user.followers.removeAll { $0 == DRConstant.userID }
                } else if !user.following.contains(DRConstant.userID) {
                    user.following.append(DRConstant.userID)
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
        let selfDocumentRef = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID)
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
                } else if !user.followers.contains(followID) {
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
        let documentRef = DRConstant.database.collection(DRConstant.user).document(userID)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    document.exists,
                    let userData = try? document.data(as: User.self)
                else { fatalError("The data structrue of user is wrong.") }
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
                        DRConstant.database
                            .collection(DRConstant.user)
                            .document(followerID)
                            .getDocument { document, error in
                                if let error = error {
                                    completion(.failure(error))
                                    downloadGroup.leave()
                                } else {
                                    guard let document = document,
                                        document.exists,
                                        let user = try? document.data(as: User.self)
                                    else {
                                        downloadGroup.leave()
                                        return
                                    }
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
        let documentReference = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID)
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
        let documentReference = DRConstant.database.collection(DRConstant.user).document(userData.userID)
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
        DRConstant.database
            .collection(DRConstant.user)
            .whereField("userSelfID", isEqualTo: selfID)
            .getDocuments { snapshot, error in
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
        DRConstant.database
            .collection(DRConstant.user)
            .whereField("userSelfID", isEqualTo: userSelfID)
            .getDocuments { snapshot, error in
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
        let documentReference = DRConstant.database.collection(DRConstant.report).document(uuid)
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
        let documentRef = DRConstant.database
            .collection(DRConstant.user)
            .document(id)
            .collection(DRConstant.diet)
            .document(mealRecord.date)
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
    
    func changeBlock(blockID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = DRConstant.database.collection(DRConstant.user).document(DRConstant.userID)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    var data = try? document.data(as: User.self)
                else { return }
                var isBlock = false
                if data.blocks.contains(blockID) {
                    data.blocks.remove(at: data.blocks.firstIndex(of: blockID) ?? 0)
                } else {
                    isBlock = true
                    data.blocks.append(blockID)
                    if data.following.contains(blockID) {
                        data.following.remove(at: data.following.firstIndex(of: blockID) ?? 0)
                    } else if data.followers.contains(blockID) {
                        data.followers.remove(at: data.followers.firstIndex(of: blockID) ?? 0)
                    }
                }
                do {
                    try documentRef.setData(from: data)
                    if isBlock {
                        self.changeOtherUser(blockID: blockID) { result in
                            switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        completion(.success(()))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func changeOtherUser(blockID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = DRConstant.database.collection(DRConstant.user).document(blockID)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = document,
                    var data = try? document.data(as: User.self)
                else { return }
                if data.following.contains(DRConstant.userID) {
                    data.following.remove(at: data.following.firstIndex(of: DRConstant.userID) ?? 0)
                } else if data.followers.contains(DRConstant.userID) {
                    data.followers.remove(at: data.followers.firstIndex(of: DRConstant.userID) ?? 0)
                }
                do {
                    try documentRef.setData(from: data)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        let collections = [DRConstant.water, DRConstant.weight, DRConstant.diet]
        for collection in collections {
            deleteGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                DRConstant.database
                    .collection(DRConstant.user)
                    .document(DRConstant.userID)
                    .collection(collection)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            guard let snapshot = snapshot
                            else {
                                deleteGroup.leave()
                                return }
                            let documents = snapshot.documents
                            if !documents.isEmpty {
                                for document in documents {
                                    DRConstant.database
                                        .collection(DRConstant.user)
                                        .document(DRConstant.userID)
                                        .collection(collection)
                                        .document(document.documentID)
                                        .delete()
                                }
                            }
                            deleteGroup.leave()
                        }
                    }
            }
            if collection == collections.last {
                deleteGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    DRConstant.database.collection(DRConstant.user).document(DRConstant.userID).delete()
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
    
    func removeFollow(allUsers: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        for otherUserID in allUsers {
            deleteGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                let documentRef = DRConstant.database.collection(DRConstant.user).document(otherUserID)
                documentRef.getDocument { document, error in
                    if let error = error {
                        completion(.failure(error))
                        deleteGroup.leave()
                    } else {
                        guard let document = document,
                            document.exists,
                            var user = try? document.data(as: User.self)
                        else {
                            deleteGroup.leave()
                            return
                        }
                        if user.following.contains(DRConstant.userID) {
                            user.following.removeAll { $0 == DRConstant.userID }
                        }
                        if user.followers.contains(DRConstant.userID) {
                            user.followers.removeAll { $0 == DRConstant.userID }
                        }
                        do {
                            try documentRef.setData(from: user)
                        } catch {
                            completion(.failure(error))
                        }
                        deleteGroup.leave()
                    }
                }
            }
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        deleteGroup.notify(queue: DispatchQueue.main) {
            completion(.success(()))
        }
    }
}
