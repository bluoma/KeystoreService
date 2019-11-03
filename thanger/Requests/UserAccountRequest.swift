//
//  UserAccountRequest.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAccountRequest: RemoteRequest {
    
    override init() {
        super.init()
        super.version = "/v2"
        super.resourcePath = "/oauth"
    }
    
    class func createAuthTokenRequest(withAuthCode authCode: String, clientId: String, clientSecret: String, redirectUri: String) -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.method = HTTPMethod.post.rawValue
        request.contentType = "application/x-www-form-urlencoded"
        request.appendPath("token")
        request.contentBody["grant_type"] = "authorization_code"
        request.contentBody["code"] = authCode
        request.contentBody["client_id"] = clientId
        request.contentBody["client_secret"] = clientSecret
        request.contentBody["redirect_uri"] = redirectUri

        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "UserAccountRequest"
    }
}
