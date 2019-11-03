//
//  UserAccountService.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAccountService {
    
    func createAuthorizationCodeRequest() -> URLRequest? {
        
        var urlRequest: URLRequest?
        
        let request = UserAuthRequest.getAuthCodeRedirectRequest(withClientId: "24ci", clientSecret: "34cs", redirectUri: oauth2RedirectUri)
        
        let obj = request.send()
        
        if let urlReq = obj as? URLRequest {
            urlRequest = urlReq
            dlog("urlRequest for sfSafari: \(urlReq)")
        }
        
        return urlRequest
    }
    
}
