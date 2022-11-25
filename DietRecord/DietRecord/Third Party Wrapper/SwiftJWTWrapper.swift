//
//  SwiftJWTWrapper.swift
//  DietRecord
//
//  Created by chun on 2022/11/25.
//

import SwiftJWT

struct MyClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: String
    let sub: String
}

class GenerateJWT {
    static let shared = GenerateJWT()
    
    let myHeader = Header(kid: "N2UB2RNM86")
    let myClaims = MyClaims(
        iss: "3JB8UHPNGJ",
        iat: Date(),
        exp: Date(timeIntervalSinceNow: 12000),
        aud: "https://appleid.apple.com",
        sub: "com.Chun.DietRecord")
    
    func fetchClientSecret() -> String? {
        var myJWT = JWT(header: myHeader, claims: myClaims)
        guard let privateKeyPath = Bundle.main.url(forResource: "AuthKey_N2UB2RNM86", withExtension: ".p8"),
            let privateKey = try? Data(contentsOf: privateKeyPath, options: .alwaysMapped)
        else { fatalError("Not find private key path.") }
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        do {
            let signedJWT = try myJWT.sign(using: jwtSigner)
            return signedJWT
        } catch {
            print(error)
            return nil
        }
    }
}
