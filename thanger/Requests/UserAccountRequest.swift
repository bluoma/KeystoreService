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
        super.version = "v2"
        super.resourcePath = "/oauth"
    }
    
    class func createAccessTokenRequest(withAuthCode authCode: String, clientId: String, clientSecret: String, redirectUri: String) -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.isTransportable = true
        request.version = ""
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
    
    class func updateAccessTokenRequest(withRefreshToken refreshToken: String, clientId: String, clientSecret: String) -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.isTransportable = true
        request.version = ""
        request.method = HTTPMethod.post.rawValue
        request.contentType = "application/x-www-form-urlencoded"
        request.appendPath("token")
        request.contentBody["grant_type"] = "refresh_token"
        request.contentBody["refresh_token"] = refreshToken
        request.contentBody["client_id"] = clientId
        request.contentBody["client_secret"] = clientSecret
        
        return request
    }
    
    
    class func deleteAccessTokenRequest(withAuthToken authToken: String) -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.isTransportable = true
        request.version = ""
        request.method = HTTPMethod.post.rawValue
        request.contentType = "application/x-www-form-urlencoded"
        request.appendPath("revoke")
        request.contentBody["token"] = authToken
        
        return request
    }
    
    class func getCurrentUserRequest() -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.isTransportable = true
        request.requiresSession = true
        request.method = HTTPMethod.get.rawValue
        request.resourcePath = "/user"
        
        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "UserAccountRequest"
    }
}
