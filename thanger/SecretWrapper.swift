//
//  KeychainWrapper.swift
//  thanger
//
//  Created by Bill on 10/30/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

protocol SecretWrapper {
    
    var service: String { get }
    var accessGroup: String? { get }
    
    init(withService service: String, accessGroup: String?)
    
    func load(key: String, value: inout Data?) -> Int
    func store(key: String, value: Data) -> Int
    func delete(key: String) -> Int
    func clear() -> Int
    func messageForStatus(status: Int) -> String

}

extension SecretWrapper {
    
    func messageForStatus(status: Int) -> String {
        let resultString: String
        
        if let message = SecCopyErrorMessageString(OSStatus(status), nil) as String? {
            resultString = message
        }
        else {
            resultString = ""
        }
       
        return resultString
    }
    
}
