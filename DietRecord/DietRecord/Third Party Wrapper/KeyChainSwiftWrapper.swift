//
//  KeyChainSwiftWrapper.swift
//  DietRecord
//
//  Created by chun on 2022/11/25.
//

import KeychainSwift

class KeyChainManager {
    static let shared = KeyChainManager()
    private let keychain = KeychainSwift()
    private let refreshToken: String = "refresh_token"
    
    func setToken(token: String) {
        keychain.set(token, forKey: refreshToken)
    }
    
    func getToken() -> String {
        return keychain.get(refreshToken) ?? ""
    }
}
