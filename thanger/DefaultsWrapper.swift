//
//  KeychainWrapper.swift
//  thanger
//
//  Created by Bill on 10/30/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class DefaultsWrapper: SecretWrapper {
    
    let service: String
    let accessGroup: String?
    
    //service not used
    required init(withService service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
    func load(key: String, value: inout Data?) -> Int {
        var status = 0
 
        guard let accessGroup = accessGroup, let sharedDefaults = UserDefaults(suiteName: accessGroup) else {
            return Int(errSecInvalidContext)
        }
        
        if let data = sharedDefaults.data(forKey: key) {
            value = data
            status = Int(errSecSuccess)
        }
        else {
            status = Int(errSecItemNotFound)
        }
        dlog("status: \(status)")
        return status
        
    }
    
    func store(key: String, value: Data) -> Int {
        
       var status = 0
        
        guard let accessGroup = accessGroup, let sharedDefaults = UserDefaults(suiteName: accessGroup) else {
            return Int(errSecInvalidContext)
        }
        
        sharedDefaults.set(value, forKey: key)
        status = Int(errSecSuccess)
                
        dlog("status: \(status)")
        return status
    }
    
    
    
    func delete(key: String) -> Int {
        
        var status = 0
        guard let accessGroup = accessGroup, let sharedDefaults = UserDefaults(suiteName: accessGroup) else {
            return Int(errSecInvalidContext)
        }
        
        sharedDefaults.removeObject(forKey: key)
        status = Int(errSecSuccess)
        dlog("status: \(status)")
        return status
    }
    
    func clear() -> Int {
        
        guard let accessGroup = accessGroup, let sharedDefaults = UserDefaults(suiteName: accessGroup) else {
            return Int(errSecInvalidContext)
        }
        /*
        let keys = sharedDefaults.dictionaryRepresentation().keys
        for key in keys {
            sharedDefaults.removeObject(forKey: key)
            dlog("removing: \(key)")
        }
        */
        let bkeys = sharedDefaults.dictionaryRepresentation().keys
        for key in bkeys {
            dlog("before key: \(key)")
        }
        
        sharedDefaults.removePersistentDomain(forName: accessGroup)
        
        let akeys = sharedDefaults.dictionaryRepresentation().keys
        for key in akeys {
            dlog("after key: \(key)")
        }
        
        return Int(errSecSuccess)
    }
}
