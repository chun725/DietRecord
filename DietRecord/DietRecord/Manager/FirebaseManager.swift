//
//  FirebaseManager.swift
//  DietRecord
//
//  Created by chun on 2022/12/7.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FSCollectionEndpoint {
    case weight
    case water
    case dietRecord(String, String)

    var collectionRef: CollectionReference {
        switch self {
        case .water:
            return DRConstant.database
                .collection(DRConstant.user)
                .document(DRConstant.userID)
                .collection(DRConstant.water)
        case .weight:
            return DRConstant.database
                .collection(DRConstant.user)
                .document(DRConstant.userID)
                .collection(DRConstant.weight)
        case .dietRecord(let id, _):
            return DRConstant.database
                .collection(DRConstant.user)
                .document(id)
                .collection(DRConstant.dietRecord)
        }
    }
}

enum FSDocumentEndpoint {
    case userData(String)
    case water(String)
    case dietRecord(String, String)
    
    var documentRef: DocumentReference {
        switch self {
        case .userData(let id):
            return DRConstant.database
                .collection(DRConstant.user)
                .document(id)
        case .water(let date):
            return DRConstant.database
                .collection(DRConstant.user)
                .document(DRConstant.userID)
                .collection(DRConstant.water)
                .document(date)
        case let .dietRecord(id, date):
            return DRConstant.database
                .collection(DRConstant.user)
                .document(id)
                .collection(DRConstant.diet)
                .document(date)
        }
    }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    
    func getDocument<T: Decodable>(_ docRef: DocumentReference, completion: @escaping (T?) -> Void) {
        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocument(snapshot: snapshot, error: error))
        }
    }


    func getDocuments<T: Decodable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }
    
    func delete(_ docRef: DocumentReference) {
        docRef.delete()
    }

    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("Debug: Error encoding \(data.self) data -", error.localizedDescription)
        }
    }
    
    private func parseDocument<T: Decodable>(snapshot: DocumentSnapshot?, error: Error?) -> T? {
        guard let snapshot = snapshot, snapshot.exists else {
            let errorMessage = error?.localizedDescription ?? ""
            print("Debug: Nil document", errorMessage)
            return nil
        }

        var model: T?
        do {
            model = try snapshot.data(as: T.self)
        } catch {
            print("Debug: Error decoding \(T.self) data -", error.localizedDescription)
        }
        return model
    }

    private func parseDocuments<T: Decodable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let errorMessage = error?.localizedDescription ?? ""
            print("Debug: Error fetching snapshot -", errorMessage)
            return []
        }

        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("Debug: Error decoding \(T.self) data -", error.localizedDescription)
            }
        }
        return models
    }
}
