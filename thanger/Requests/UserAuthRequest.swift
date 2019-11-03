//
//  UserAuthRequest.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAuthRequest: RemoteRequest {
    
    override init() {
        super.init()
        super.version = "/v2"
        super.resourcePath = "/oauth"
    }
    
    class func getAuthCodeRedirectRequest(withClientId clientId: String, clientSecret: String, redirectUri: String) -> UserAuthRequest {
        let request = UserAuthRequest()
        request.isTransportable = false
        request.method = HTTPMethod.get.rawValue
        request.appendPath("authorize")
        request.params["response_type"] = "code"
        request.params["client_id"] = clientId
        request.params["client_secret"] = clientSecret
        request.params["redirect_uri"] = redirectUri
        request.params["state"] = UUID().uuidString
        request.params["scope"] = "wallet:user:read,wallet:user:email,wallet:accounts:read"
        
        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "UserAuthRequest"
    }
}
