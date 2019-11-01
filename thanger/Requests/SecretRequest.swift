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

class SecretRequest<Keystore: SecretWrapper> {
    
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
    
    //non-escaping closure, so this executes synchonously
    func send(completion: ((Secret?, Error?) -> Void)) {
        dlog("currentThread: \(Thread.current)")
        
        switch method {
            
        case .load:
            load(completion: completion)
        case .store:
            store(completion: completion)
        case .delete:
            delete(completion: completion)
        case .clear:
            clear(completion: completion)
        }
        
    }
    
    //non-escaping closure, so this executes synchonously
    func load(completion: ((Secret?, Error?) -> Void)) {
        dlog("load")

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
                    completion(secret, nil)
                }
                else {
                    let error = ServiceError(type: .dataNotFound, code: Int(errSecDataNotAvailable), msg: "data not found in keystore item")
                    dlog("keystore error: \(error)")
                    completion(nil, error)
                }
            }
            catch {
                dlog("error decoding data: \(error)")
                completion(nil, error)
            }
            
        default:
            let msg = keystore.messageForStatus(status: loadStatus)
            let error = ServiceError(type: .invalidData, code: loadStatus, msg: msg)
            dlog("keystore error: \(error)")
            completion(nil, error)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func store(completion: ((Secret?, Error?) -> Void)) {
        dlog("store")

        let secretToStore = Secret(secretKey: secretKey, secretVal: secretVal, secretType: secretType)
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(secretToStore)
            let storeStatus = keystore.store(key: secretKey, value: jsonData)
            let status = OSStatus(storeStatus)
            if status == errSecSuccess {
                completion(secretToStore, nil)
            }
            else {
                let msg = keystore.messageForStatus(status: storeStatus)
                let error = ServiceError(type: .invalidData, code: storeStatus, msg: msg)
                dlog("keystore error: \(error)")
                completion(nil, error)
            }
        }
        catch {
            dlog("encoding error: \(error)")
            completion(nil, error)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func delete(completion: ((Secret?, Error?) -> Void)) {
        dlog("delete")
        
        let deleteStatus = keystore.delete(key: secretKey)
        let status = OSStatus(deleteStatus)
        switch status {
         
        case errSecSuccess:
            completion(nil, nil)
            
        case errSecItemNotFound:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .dataKeyNotFound, code: deleteStatus, msg: msg)
            dlog("key not found: \(error)")
            completion(nil, error)
            
        default:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .invalidData, code: deleteStatus, msg: msg)
            dlog("keystore error: \(error)")
            completion(nil, error)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func clear(completion: ((Secret?, Error?) -> Void)) {
        dlog("clear")
        
        let deleteStatus = keystore.clear()
        let status = OSStatus(deleteStatus)
        switch status {
         
        case errSecSuccess:
            completion(nil, nil)
            
        case errSecItemNotFound:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .dataKeyNotFound, code: deleteStatus, msg: msg)
            dlog("service not found: \(error)")
            completion(nil, error)
            
        default:
            let msg = keystore.messageForStatus(status: deleteStatus)
            let error = ServiceError(type: .invalidData, code: deleteStatus, msg: msg)
            dlog("keystore error: \(error)")
            completion(nil, error)
        }
    }
}
