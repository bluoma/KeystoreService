//
//  SecretRequest.swift
//  thanger
//
//  Created by Bill on 10/30/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

enum SecretRequestMethod: String {
    case load = "load"
    case store = "store"
    case delete = "delete"
    case clear = "clear"
}

class SecretRequest<Keystore: SecretWrapper>: RequestProtocol {
    
    lazy var keystore: Keystore = {
        let newKestore = Keystore(withService: service, accessGroup: accessGroup)
        return newKestore
    } ()
    
    let secretType: SecretType
    let secretKey: String
    let secretVal: String
    let service: String
    let accessGroup: String?
    let method: SecretRequestMethod
    var isTransportable: Bool = false
    
    init(withMethod method: SecretRequestMethod, secretType: SecretType, secretKey: String, service: String, accessGroup: String? = nil) {
        self.method = method
        self.secretType = secretType
        self.secretKey = secretKey
        self.secretVal = ""
        self.service = service
        self.accessGroup = accessGroup
    }
    
    init(withMethod method: SecretRequestMethod, secretType: SecretType, secretKey: String, secretVal: String, service: String, accessGroup: String? = nil) {
        self.method = method
        self.secretType = secretType
        self.secretVal = secretVal
        self.secretKey = secretKey
        self.service = service
        self.accessGroup = accessGroup
    }
    
    class func fetchSecretRequest(withSecret secret: Secret) -> SecretRequest {
        
        let request = SecretRequest(withMethod: .load, secretType: secret.secretType, secretKey: secret.secretKey, service: sharedKeychainService, accessGroup: sharedKeychainGroup)
                
        return request
    }
    
    class func storeSecretRequest(withSecret secret: Secret) -> SecretRequest {
        
        let request = SecretRequest(withMethod: .store, secretType: secret.secretType, secretKey: secret.secretKey, secretVal: secret.secretVal, service: sharedKeychainService, accessGroup: sharedKeychainGroup)
        
        return request
    }
    
    class func deleteSecretRequest(withSecret secret: Secret) -> SecretRequest {
        
        let request = SecretRequest(withMethod: .delete, secretType: secret.secretType, secretKey: secret.secretKey, service: sharedKeychainService, accessGroup: sharedKeychainGroup)
        
        return request
    }
    
    class func deleteAllSecretsRequest() -> SecretRequest {
        
        let request = SecretRequest(withMethod: .clear, secretType: .none, secretKey: "", service: sharedKeychainService, accessGroup: sharedKeychainGroup)
        
        return request
    }
    
    //methods that don't take a closure argument, but return a tuple
    func load() -> (Secret?, Error?) {
        dlog("load")
        
        var result: (s: Secret?, e: Error?)
        var data: Data?
        let loadStatus = keystore.load(key: secretKey, value: &data)
        let status = OSStatus(loadStatus)
        switch status {
            
        case errSecSuccess:
            dlog("success")
            do {
                let decoder = JSONDecoder()
                if let data = data {
                    let secret = try decoder.decode(Secret.self, from: data)
                    result.s = secret
                }
                else {
                    let error = ServiceError(type: .dataNotFound, code: Int(errSecDataNotAvailable), msg: "data not found in keystore item")
                    dlog("keystore error: \(error)")
                    result.e = error
                }
            }
            catch {
                dlog("error decoding data: \(error)")
                result.e = error
            }
            
        default:
            let msg = keystore.messageForStatus(status: loadStatus)
            let error = ServiceError(type: .invalidData, code: loadStatus, msg: msg)
            dlog("keystore error: \(error)")
            result.e = error
        }
        return result
    }
    
    func store() -> (Secret?, Error?) {
        dlog("store")
        var result: (s: Secret?, e: Error?)
        let secretToStore = Secret(secretKey: secretKey, secretVal: secretVal, secretType: secretType)
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(secretToStore)
            let storeStatus = keystore.store(key: secretKey, value: jsonData)
            let status = OSStatus(storeStatus)
            if status == errSecSuccess {
                result.s = secretToStore
            }
            else {
                let msg = keystore.messageForStatus(status: storeStatus)
                let error = ServiceError(type: .invalidData, code: storeStatus, msg: msg)
                dlog("keystore error: \(error)")
                result.e = error
            }
        }
        catch {
            dlog("encoding error: \(error)")
            result.e = error
        }
        
        return result
    }
    
    func delete() -> (Secret?, Error?) {
        dlog("delete")
        var result: (s: Secret?, e: Error?)
        let deleteStatus = keystore.delete(key: secretKey)
        let status = OSStatus(deleteStatus)
        switch status {
         
        case errSecSuccess:
            result.s = nil
            result.e = nil
            
        case errSecItemNotFound:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .dataKeyNotFound, code: deleteStatus, msg: msg)
            dlog("key not found: \(error)")
            result.e = error
            
        default:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .invalidData, code: deleteStatus, msg: msg)
            dlog("keystore error: \(error)")
            result.e = error
        }
        return result
    }
    
    func clear() -> (Secret?, Error?) {
        dlog("clear")
        var result: (s: Secret?, e: Error?)
        let deleteStatus = keystore.clear()
        let status = OSStatus(deleteStatus)
        switch status {
         
        case errSecSuccess:
            result.s = nil
            result.e = nil
            
        case errSecItemNotFound:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .dataKeyNotFound, code: deleteStatus, msg: msg)
            dlog("service not found: \(error)")
            result.e = error
            
        default:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .invalidData, code: deleteStatus, msg: msg)
            dlog("keystore error: \(error)")
            result.e = error
        }
        return result
    }
    
    func send() -> Any? {
        
        switch method {
            
        case .load:
            return load()
        case .store:
            return store()
        case .delete:
            return delete()
        case .clear:
            return clear()
            
        }
    }
}
