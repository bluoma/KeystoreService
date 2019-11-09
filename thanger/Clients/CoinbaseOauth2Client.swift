//
//  CoinbaseOauth2Client.swift
//  thanger
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class CoinbaseOauth2Client: CoinbaseHttpClient {
    
    let secretService = SecretService()
    let userAccountService = UserAccountService()
    let maxRetryCount = 3
    var urlRequestDict: [String: Error] = [:]
    
    override init() {
        super.init(withScheme: "https", host: "api.coinbase.com")
        transport.shouldRetryBlock = retry(requestId:error:)
    }
    
    override init(withScheme scheme: String, host: String, port: String = "") {
        super.init(withScheme: scheme, host: host, port: port)
        transport.shouldRetryBlock = retry(requestId:error:)
    }
    
    fileprivate func getAccessToken() -> OAuth2Credential? {
        var error: Error?
        var secret: Secret?
        let searchSecret = Secret(secretKey: SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred)

        self.secretService.fetchSecret(searchSecret) { (s: Secret?, e: Error?) in
            secret = s
            error = e
        }
        guard let foundSecret = secret, let cred = foundSecret.secretValue as? OAuth2Credential else {
            dlog("error fetching authToken: \(String(describing: error))")
            return nil
        }
        return cred
    }
    
    func handleRetrySend(forRequestId requestId: String) {
        
        guard let remoteRequest = NetworkPlatform.shared.request(forId: requestId) else {
            dlog("no request for id: \(requestId)")
            urlRequestDict[requestId] = nil
            assert(false, "no request for id: \(requestId)")
            return
        }
        
        if !remoteRequest.blockCalled {
            if remoteRequest.retryCount < maxRetryCount {
                dlog("resending remote request:\(requestId), \(remoteRequest.resourcePath)")
                remoteRequest.send()
                remoteRequest.retryCount += 1
            }
            else {
                guard let error = urlRequestDict[requestId] else { return }
                remoteRequest.failureBlock?(error)
                remoteRequest.blockCalled = true
                NetworkPlatform.shared.removeRequest(forId: requestId)
            }
        }
        else {
            dlog("remote request block already called requestId: \(requestId), \(remoteRequest.resourcePath)")
            NetworkPlatform.shared.removeRequest(forId: requestId)
        }

        urlRequestDict[requestId] = nil
    }
    
    func handleRetryFailure(forRequestId requestId: String) {
        
        guard let remoteRequest = NetworkPlatform.shared.request(forId: requestId),
            let error = urlRequestDict[requestId] else {
            dlog("no request for id: \(requestId)")
            urlRequestDict[requestId] = nil
            return
        }
        
        defer {
            NetworkPlatform.shared.removeRequest(forId: requestId)
        }
        
        guard remoteRequest.blockCalled == false else { return }
        remoteRequest.failureBlock?(error)
        remoteRequest.blockCalled = true
        urlRequestDict[requestId] = nil
    }
    
    func refreshAccessToken(forRequestId requestId: String) {
        
        userAccountService.refreshAccessToken { [weak self] (recred: OAuth2Credential?, error: Error?) in
                   
            guard let myself = self else { return }
            
            guard error == nil else {
                dlog("error refreshing accessToken: \(error!)")
                //TODO probably should retry this w backoff strategy
                self?.handleRetryFailure(forRequestId: requestId)
                return
            }
            
            guard let _ = recred else {
                assert(false, "we should have cred if error is nil")
                return
            }
            
            DispatchQueue.main.async {
                myself.handleRetrySend(forRequestId: requestId)
            }
        }
    }
    
    func retry(requestId: String, error: ServiceError) -> Void {
        
        dlog("retry: error: \(error)")
        
        guard error.code == 401 else {
            dlog("not a 401 or no requestId header, bailing")
            self.handleRetryFailure(forRequestId: requestId)
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.urlRequestDict[requestId] = error
            
            if let cred = self?.getAccessToken() {
                if cred.isExpired {
                    self?.refreshAccessToken(forRequestId: requestId)
                }
                else {
                    self?.handleRetrySend(forRequestId: requestId)
                }
            }
            else {
                //TODO need user to login, send notification?
                self?.handleRetryFailure(forRequestId: requestId)
            }
        }
    }
    
    override func buildUrl(withRequest request: RemoteRequest) -> URL? {
     
        return super.buildUrl(withRequest: request)
    }
    
    override func buildUrlRequest(withRemoteRequest request: RemoteRequest) -> URLRequest? {
        
        var urlRequest: URLRequest?
        var localHeaders = headers
        guard let url = buildUrl(withRequest: request) else { return nil }
            
        var theUrlRequest = URLRequest(url: url)
        theUrlRequest.httpMethod = request.method
        
        if request.contentBody.isEmpty {
            urlRequest = theUrlRequest
        }
        else {
            switch request.contentType {
            case "application/json":
                do {
                    let data = try JSONSerialization.data(withJSONObject: request.contentBody, options: [])
                    theUrlRequest.httpBody = data
                    urlRequest = theUrlRequest
                    localHeaders["Content-Type"] = "application/json"
                }
                catch {
                    dlog(String(describing: error))
                }
            case "application/x-www-form-urlencoded":
                var bodyArray: [String] = []
                for (key, val) in request.contentBody {
                    let keyVal = "\(key)=\(val)"
                    bodyArray.append(keyVal)
                }
                let bodyString = bodyArray.joined(separator: "&")
                dlog("bodyStringNotEncoded: \(bodyString)")
                //var allowed = CharacterSet.alphanumerics
                //allowed.insert(charactersIn: "-._~") // as per RFC 3986
                //if let percentEncoded = bodyString.addingPercentEncoding(withAllowedCharacters: allowed) {
                    //bodyString = percentEncoded
                //}
                //dlog("bodyStringEncoded: \(bodyString)")
                if let data = bodyString.data(using: .utf8) {
                    theUrlRequest.httpBody = data
                    urlRequest = theUrlRequest
                    localHeaders["Content-Type"] = "application/x-www-form-urlencoded"
                }
                else {
                    assert(false, "bad post body: \(bodyString)")
                }
            default:
                dlog("unsupported contentType: \(request.contentType)")
            }
        }
       
        if request.requiresSession {
            //add oauth access token to Authorization header
            if let cred = getAccessToken() {
                localHeaders["Authorization"] = "Bearer \(cred.accessToken)"
            }
            else {
                dlog("no session, bailing")
                return nil
            }
        }
        if !localHeaders.isEmpty {
            urlRequest?.allHTTPHeaderFields = localHeaders
        }
                
        return urlRequest
    }
    
    @discardableResult //forward to transport
    override func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return transport.send(urlRequest: request, completion: completion)
    }
    
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "CoinbaseOauth2Client"
    }
}
