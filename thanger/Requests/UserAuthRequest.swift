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
        super.version = ""
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
        if let encodedUri = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            request.params["redirect_uri"] = encodedUri
        }
        else {
            request.params["redirect_uri"] = redirectUri
        }
        
        request.params["state"] = UUID().uuidString
        request.params["scope"] = "wallet:user:read,wallet:accounts:read"
        
        return request
    }
    
    class func createAuthTokenRequest(withAuthCode authCode: String, clientId: String, clientSecret: String, redirectUri: String) -> UserAuthRequest {
        
        let request = UserAuthRequest()
        request.isTransportable = true
        request.method = HTTPMethod.post.rawValue
        request.contentType = "application/x-www-form-urlencoded"
        request.appendPath("token")
        request.contentBody["grant_type"] = "authorization_code"
        request.contentBody["code"] = authCode
        request.contentBody["client_id"] = clientId
        request.contentBody["client_secret"] = clientSecret
        if let encodedUri = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            request.contentBody["redirect_uri"] = encodedUri
        }
        else {
            request.contentBody["redirect_uri"] = redirectUri
        }
        
        
        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "UserAuthRequest"
    }
}
