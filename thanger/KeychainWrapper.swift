//
//  KeychainWrapper.swift
//  thanger
//
//  Created by Bill on 10/30/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class KeychainWrapper: SecretWrapper {
    
    let service: String
    let accessGroup: String?
    
    required init(withService service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    func load(key: String, value: inout Data?) -> Int {
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnAttributes as String: kCFBooleanTrue as Any,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        if status == errSecSuccess {
            
            guard let queriedItem = queryResult as? [String: Any],
                let secretData = queriedItem[kSecValueData as String] as? Data else {
                    dlog("error getting data from resultDict")
                    return Int(errSecInvalidData)
            }
            value = secretData
        }
        
        return Int(status)
        
    }
    
    func store(key: String, value: Data) -> Int {
        
        var status = errSecItemNotFound
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnAttributes as String: kCFBooleanFalse as Any
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let searchStatus = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch searchStatus {
            
        case errSecItemNotFound:
            query[kSecValueData as String] = value
            status = SecItemAdd(query as CFDictionary, nil)
            
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[kSecValueData as String] = value
            dlog("found existing secret in keychain, need to update")
            status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
        default:
            let errMsg = messageForStatus(status: Int(searchStatus))
            dlog("error \(searchStatus), \(errMsg)")
            status = searchStatus
        }
        
        return Int(status)
    }
    
    
    
    func delete(key: String) -> Int {
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        return Int(status)
    }
    
    func clear() -> Int {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        return Int(status)
    }
}
