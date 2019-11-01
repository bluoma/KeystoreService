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
        
        let secretRequest: SecretRequest<DefaultsWrapper> = SecretRequest.fetchSecretRequest(
            withSecret: searchSecret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, executes synchronously
    func storeSecret(_ secret: Secret, completion: (Secret?, Error?) -> Void) {
        
        let secretRequest: SecretRequest<DefaultsWrapper> = SecretRequest.storeSecretRequest(withSecret: secret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, executes synchronously
    func deleteSecret(_ secret: Secret, completion: ((Secret?, Error?) -> Void)) {
                 
        let secretRequest: SecretRequest<DefaultsWrapper> = SecretRequest.deleteSecretRequest(withSecret: secret)
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
    //non-escaping closure, executes synchonrously
    func clearAllSecrets(completion: ((Secret?, Error?) -> Void)) {
                 
        let secretRequest: SecretRequest<DefaultsWrapper> = SecretRequest.deleteAllSecretsRequest()
        
        dispatchQueue.sync {
            secretRequest.send(completion: completion)
        }
    }
    
}
