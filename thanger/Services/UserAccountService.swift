//
//  UserAccountService.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAccountService {
    
    let secretService = SecretService()
    
    func createAuthorizationCodeRequest(withRedirectUrl redir: String) -> URLRequest? {
        
        var urlRequest: URLRequest?
        var clientId: String?
        var clientSecret: String?
        
        let s1 = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretType: .string)
        secretService.fetchSecret(s1) { (clientIdSecret: Secret?, error: Error?) in
            clientId = clientIdSecret?.secretValue as? String
        }
        let s2 = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretType: .string)
        secretService.fetchSecret(s2) { (clientSecretSecret: Secret?, error: Error?) in
            clientSecret = clientSecretSecret?.secretValue as? String
        }
        
        guard let foundClientId = clientId, let foundClientSecret = clientSecret else {
            return nil
        }
        
        let request = UserAuthRequest.getAuthCodeRedirectRequest(withClientId: foundClientId, clientSecret: foundClientSecret, redirectUri: redir)
        
        let obj = request.send()
        
        if let urlReq = obj as? URLRequest {
            urlRequest = urlReq
            dlog("urlRequest for webview: \(urlReq)")
        }
        
        return urlRequest
    }
    
    func createAccessToken(withAuthCode authCode: String, completion: @escaping ((OAuth2Credential?, Error?) -> Void)) {
        
        var clientId: String?
        var clientSecret: String?
        
        let s1 = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretType: .string)
        secretService.fetchSecret(s1) { (clientIdSecret: Secret?, error: Error?) in
            clientId = clientIdSecret?.secretValue as? String
        }
        let s2 = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretType: .string)
        secretService.fetchSecret(s2) { (clientSecretSecret: Secret?, error: Error?) in
            clientSecret = clientSecretSecret?.secretValue as? String
        }
        
        guard let foundClientId = clientId, let foundClientSecret = clientSecret else {
            let error = ServiceError(type: .dataNotFound, code: -2, msg: "error getting client id/secret")
            completion(nil, error)
            return
        }
        
        let redir = coinbaseOAuth2RedirectUri
        
        let request = UserAccountRequest.createAccessTokenRequest(withAuthCode: authCode, clientId: foundClientId, clientSecret: foundClientSecret, redirectUri: redir)
        
        request.successBlock = { [weak self] (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            guard let myself = self else { return }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let cred = try decoder.decode(OAuth2Credential.self, from: data)
                    
                    dlog("cred: \(cred)")
                    let credSecret = Secret(secretKey: SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred, secretValue: cred)
                    myself.secretService.storeSecret(credSecret) { (result: Secret?, error: Error?) in
                        dlog("storeAcessToken: \(error == nil ? "success" : "failure")")
                    }
                    completion(cred, nil)
                    
                }
                catch {
                    dlog("error decoding data: \(error)")
                    completion(nil, error)
                }
            }
            else {
                let error = ServiceError(type: .dataNotFound, code: -404, msg: "data not found for authCode")
                dlog("error: \(error)")
                completion(nil, error)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        
        request.send()
    }
    
    func refreshAccessToken(completion: @escaping ((OAuth2Credential?, Error?) -> Void)) {
        
        var clientId: String?
        var clientSecret: String?
        var refreshToken: String?
        
        let s1 = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretType: .string)
        secretService.fetchSecret(s1) { (clientIdSecret: Secret?, error: Error?) in
            clientId = clientIdSecret?.secretValue as? String
        }
        let s2 = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretType: .string)
        secretService.fetchSecret(s2) { (clientSecretSecret: Secret?, error: Error?) in
            clientSecret = clientSecretSecret?.secretValue as? String
        }
        let s3 = Secret(secretKey: SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred)
        secretService.fetchSecret(s3) { (credSecret: Secret?, error: Error?) in
            let cred = credSecret?.secretValue as? OAuth2Credential
            refreshToken = cred?.refreshToken
        }
        
        guard let foundClientId = clientId,
            let foundClientSecret = clientSecret,
            let foundRefreshToken = refreshToken else {
                let error = ServiceError(type: .dataNotFound, code: -404, msg: "error getting client id/secret/cred")
                completion(nil, error)
                return
        }
        
        let request = UserAccountRequest.updateAccessTokenRequest(withRefreshToken: foundRefreshToken, clientId: foundClientId, clientSecret: foundClientSecret)
        
        request.successBlock = { [weak self] (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            guard let myself = self else { return }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let cred = try decoder.decode(OAuth2Credential.self, from: data)
                    
                    dlog("cred: \(cred)")
                    let credSecret = Secret(secretKey: SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred, secretValue: cred)
                    myself.secretService.storeSecret(credSecret) { (result: Secret?, error: Error?) in
                        dlog("storeAcessToken: \(error == nil ? "success" : "failure")")
                    }
                    completion(cred, nil)
                    
                }
                catch {
                    dlog("error decoding data: \(error)")
                    completion(nil, error)
                }
            }
            else {
                let error = ServiceError(type: .dataNotFound, code: -404, msg: "data not found for authCode")
                dlog("error: \(error)")
                completion(nil, error)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        
        request.send()
    }
    
    func getCurrentUser(completion: @escaping ((User?, Error?) -> Void)) {
        let request = UserAccountRequest.getCurrentUserRequest()
        
        request.successBlock = { [weak self] (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            guard let _ = self else { return }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: data)
                    dlog("user: \(user)")
                    completion(user, nil)
                }
                catch {
                    dlog("error decoding data: \(error)")
                    completion(nil, error)
                }
            }
            else {
                let error = ServiceError(type: .dataNotFound, code: -404, msg: "data not found for authCode")
                dlog("error: \(error)")
                completion(nil, error)
            }
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        
        request.send()
    }
}
