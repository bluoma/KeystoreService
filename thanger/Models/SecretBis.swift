//
//  SecretBis.swift
//  thanger
//
//  Created by Bill on 11/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


protocol SecretProtocol: Codable, Equatable {
    associatedtype SecretValue: Codable, Equatable
    
    var secretKey: String { get }
    var secretType: SecretType { get }
    var secretValue: SecretValue? { get }
}


struct SecretString: SecretProtocol, CustomStringConvertible {
    typealias SecretValue = String
    
    let secretKey: String
    let secretType: SecretType
    let secretValue: String?
    
    var description: String {
        return "\(secretKey):\(secretType.rawValue):\(String(describing: secretValue))"
    }
    
    init(secretKey: String, secretType: SecretType, secretValue: String? = nil) {
        self.secretKey = secretKey
        self.secretType = secretType
        self.secretValue = secretValue
    }
    
    static func ==(lhs: SecretString, rhs: SecretString) -> Bool {
         return lhs.secretKey == rhs.secretKey
             && lhs.secretType == rhs.secretType
            && lhs.secretValue == rhs.secretValue
    }
    
}

struct SecretOAuth2Credential: SecretProtocol, CustomStringConvertible {
    typealias SecretValue = OAuth2Credential
    
    let secretKey: String
    let secretType: SecretType
    let secretValue: OAuth2Credential?
    
    var description: String {
        return "\(secretKey):\(secretType.rawValue):\(String(describing: secretValue))"
    }
    
    init(secretKey: String, secretType: SecretType, secretValue: OAuth2Credential? = nil) {
        self.secretKey = secretKey
        self.secretType = secretType
        self.secretValue = secretValue
    }
    
    static func ==(lhs: SecretOAuth2Credential, rhs: SecretOAuth2Credential) -> Bool {
         return lhs.secretKey == rhs.secretKey
             && lhs.secretType == rhs.secretType
            && lhs.secretValue == rhs.secretValue
    }
}


class SecretBis<V: Codable>: Codable, CustomStringConvertible, Hashable {
    
    var secretKey: String
    var secretType: SecretType
    var secretValue: V?
    
    init(secretKey: String, secretType: SecretType, secretValue: V?) {
        self.secretKey = secretKey
        self.secretType = secretType
        self.secretValue = secretValue
    }
    
    var description: String {
        return "key: \(secretKey), type: \(secretType), val: \(String(describing: secretValue))"
    }
    
    static func ==(lhs: SecretBis, rhs: SecretBis) -> Bool {
        return lhs.secretKey == rhs.secretKey
            && lhs.secretType == rhs.secretType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(secretKey)
        hasher.combine(secretType)
    }
}
