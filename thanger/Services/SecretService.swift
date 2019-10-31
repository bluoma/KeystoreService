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
    
    //non-escaping closure, so this executes synchonously
    func fetchSecret(_ searchSecret: Secret, completion: ((Secret?, Error?) -> Void)) {
        
        let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.fetchSecretRequest(
            withSecret: searchSecret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func storeSecret(_ secret: Secret, completion: (Secret?, Error?) -> Void) {
        
        let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.storeSecretRequest(withSecret: secret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func deleteSecret(_ secret: Secret, completion: ((Secret?, Error?) -> Void)) {
                 
        let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.deleteSecretRequest(withSecret: secret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, so this executes synchonously
    func clearAllSecrets(completion: ((Secret?, Error?) -> Void)) {
                 
        let secretRequest: SecretRequest<KeychainWrapper> = SecretRequest.deleteAllSecretsRequest()
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
}
