//
//  SecretService.swift
//  thanger
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class SecretService {
    
    let dispatchQueue = DispatchQueue(label: "SecretServiceDispatchQueue")
    
    //non-escaping closure, executes synchronously
    func fetchSecret(_ searchSecret: Secret, completion: ((Secret?, Error?) -> Void)) {
        dispatchQueue.sync {
            let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.fetchSecretRequest(
                withSecret: searchSecret)
            
            if let result: (s: Secret?, e: Error?) = secretRequest.send() as? (Secret?, Error?) {
                completion(result.s, result.e)
            }
            else {
                preconditionFailure("bad return value from SecretRequest.send")
            }
        }
    }
    
    //non-escaping closure, executes synchronously
    func storeSecret(_ secret: Secret, completion: (Secret?, Error?) -> Void) {
        dispatchQueue.sync {
            let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.storeSecretRequest(withSecret: secret)
            
            if let result: (s: Secret?, e: Error?) = secretRequest.send() as? (Secret?, Error?) {
                completion(result.s, result.e)
            }
            else {
                preconditionFailure("bad return value from SecretRequest.send")
            }
        }
    }
    
    //non-escaping closure, executes synchronously
    func deleteSecret(_ secret: Secret, completion: ((Secret?, Error?) -> Void)) {
        dispatchQueue.sync {
            let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.deleteSecretRequest(withSecret: secret)
            
            if let result: (s: Secret?, e: Error?) = secretRequest.send() as? (Secret?, Error?) {
                completion(result.s, result.e)
            }
            else {
                preconditionFailure("bad return value from SecretRequest.send")
            }
        }
    }
    
    //non-escaping closure, executes synchronrously
    func clearAllSecrets(completion: ((Secret?, Error?) -> Void)) {
        dispatchQueue.sync {
            let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.deleteAllSecretsRequest()
            
            if let result: (s: Secret?, e: Error?) = secretRequest.send() as? (Secret?, Error?) {
                completion(result.s, result.e)
            }
            else {
                preconditionFailure("bad return value from SecretRequest.send")
            }
        }
    }
    
}
