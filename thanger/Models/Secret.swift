//
//  Secret.swift
//  thanger
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


struct SecretKeys {
    
    static let coinbaseClientIdKey = "coinbaseClientIdKey"
    static let coinbaseClientSecretKey = "coinbaseClientSecretKey"
    static let coinbaseOAuthCredentialKey = "coinbaseOAuthCredentialKey"

    static let allValues: [String] = [coinbaseClientIdKey, coinbaseClientSecretKey, coinbaseOAuthCredentialKey]
    
}

enum SecretType: String, Codable {
    
    case string = "string"
    case oauthCred = "oauthCred"
    case none = "none"
    
}


struct Secret: CustomStringConvertible, Equatable {
    
    var secretKey: String = ""
    var secretType: SecretType = .none
    var secretValue: Any?
    
    var description: String {
        return "\(secretKey):\(secretType.rawValue)"
    }
    
    init(secretKey: String, secretType: SecretType, secretValue: Any? = nil) {
        self.secretKey = secretKey
        self.secretType = secretType
        self.secretValue = secretValue
    }
    
    static func ==(lhs: Secret, rhs: Secret) -> Bool {
         return lhs.secretKey == rhs.secretKey
             && lhs.secretType == rhs.secretType
    }
    
}

extension Secret: Encodable {
    
    enum EncodingKeys: String, CodingKey {
        case secretKey
        case secretType
        case secretValue
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: EncodingKeys.self)
            try container.encode(secretKey, forKey: .secretKey)
            try container.encode(secretType, forKey: .secretType)
            
            switch secretType {
                
            case .oauthCred:
                let oauthCred = secretValue as? OAuth2Credential
                try container.encodeIfPresent(oauthCred, forKey: .secretValue)
                
            case .string:
                let secretString = secretValue as? String
                try container.encodeIfPresent(secretString, forKey: .secretValue)
                
            default:
                dlog("unsuported secretType: \(secretType.rawValue)")
                let error = ServiceError(type: .invalidData, code: -2, msg: "unsuported secretType: \(secretType.rawValue)")
                throw error
            }
           
        }
        catch {
            dlog("error encoding secret: \(error)")
            throw error
        }
    }
}

extension Secret: Decodable {
    
    enum DecodingKeys: String, CodingKey {
        case secretKey
        case secretType
        case secretValue
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: DecodingKeys.self)
            secretKey = try container.decode(String.self, forKey: .secretKey)
            secretType = try container.decode(SecretType.self, forKey: .secretType)
            
            switch secretType {
                
            case .oauthCred:
                secretValue = try container.decodeIfPresent(OAuth2Credential.self, forKey: .secretValue)
                
            case.string:
                secretValue = try container.decodeIfPresent(String.self, forKey: .secretValue)

            default:
                dlog("unsuported secretType: \(secretType.rawValue)")
                let error = ServiceError(type: .invalidData, code: -2, msg: "unsuported secretType: \(secretType.rawValue)")
                throw error
            }
        }
        catch {
            dlog("error decoding secret: \(error)")
            throw error
        }
    }
}

struct OAuth2Credential: CustomStringConvertible, Equatable {
    
    let accessToken: String
    let refreshToken: String
    let scope: String
    let tokenType: String
    //unix timestamp, seconds since j1 1970
    let createdAt: Int
    //seconds, usually 7200: 2 hours
    let expiresIn: Int
    
    var isExpired: Bool {
        let now = Date()
        let expirationDate = Date(timeIntervalSince1970: TimeInterval((createdAt + expiresIn)))
        dlog("now: \(now), expirationDate: \(expirationDate)")
        return expirationDate < now
    }
    
    var description: String {
        var desc = "\naccessToken: \(accessToken), refreshToken: \(refreshToken), scope: \(scope)"
        desc += "\ntokenType: \(tokenType), isExpired: \(isExpired)"
        return desc
    }
    
    static func ==(lhs: OAuth2Credential, rhs: OAuth2Credential) -> Bool {
        return lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.createdAt == rhs.createdAt
            && lhs.expiresIn == rhs.expiresIn
    }
}

extension OAuth2Credential: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case scope = "scope"
        case tokenType = "token_type"
        case createdAt = "created_at"
        case expiresIn = "expires_in"
      
    }
}

