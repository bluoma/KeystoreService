//
//  Secret.swift
//  thanger
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


struct SecretKeys {
    
    static let coinbaseAccessTokenKey = "coinbaseAccessTokenKey"
    static let coinbaseRefreshTokenKey = "coinbaseRefreshTokenKey"
    static let coinbaseClientIdKey = "coinbaseClientIdKey"
    static let coinbaseClientSecretKey = "coinbaseClientSecretKey"
    static let allValues: [String] = [coinbaseAccessTokenKey, coinbaseRefreshTokenKey, coinbaseClientIdKey, coinbaseClientSecretKey]
    
}

enum SecretType: String, Codable {
    
    case clientId = "clientId"
    case clientSecret = "clientSecret"
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
    case none = "none"
    
}

class Secret: Codable, CustomStringConvertible, Hashable {
    
    var secretKey: String = ""
    var secretVal: String = ""
    var secretType: SecretType = .none
    var expirationDate: Date?
    
    init(secretKey: String, secretVal: String, secretType: SecretType, expirationDate: Date? = nil) {
        self.secretKey = secretKey
        self.secretVal = secretVal
        self.secretType = secretType
        self.expirationDate = expirationDate
    }
    
    
    enum CodingKeys: String, CodingKey {
        case secretKey
        case secretVal
        case secretType
        case expirationDate
    }
    
    var description: String {
        return "\(secretKey):\(secretVal):\(secretType.rawValue)"
    }
    
    static func ==(lhs: Secret, rhs: Secret) -> Bool {
        return lhs.secretKey == rhs.secretKey
            && lhs.secretVal == rhs.secretVal
            && lhs.secretType == rhs.secretType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(secretKey)
        hasher.combine(secretVal)
        hasher.combine(secretType)
    }
}
