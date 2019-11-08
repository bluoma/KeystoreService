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
    
    var retryContainer: Set<RemoteRequest> = []
    var urlRequestDict: [String: (URLRequest, Error)] = [:]
    
    override init() {
        super.init(withScheme: "https", host: "api.coinbase.com")
        transport.shouldRetryBlock = retry(urlRequest:error:)
    }
    
    override init(withScheme scheme: String, host: String, port: String = "") {
        super.init(withScheme: scheme, host: host, port: port)
        transport.shouldRetryBlock = retry(urlRequest:error:)
    }
    
    
    func handleRetrySend() {
        
        for remoteRequest in retryContainer {
            let requestId = remoteRequest.requestId
            guard let (_, error) = urlRequestDict[requestId] else { continue }
            if !remoteRequest.blockCalled {
                if remoteRequest.retryCount < 3 {
                    dlog("resending remote request:\(requestId), \(remoteRequest.resourcePath)")
                    remoteRequest.send()
                    remoteRequest.retryCount += 1
                }
                else {
                    remoteRequest.failureBlock?(error)
                }
            }
            else {
                dlog("remote request block already called requestId: \(requestId), \(remoteRequest.resourcePath)")
            }
            retryContainer.remove(remoteRequest)
            urlRequestDict[requestId] = nil
        }
    }
    
    func refreshAccessToken() {
        userAccountService.refreshAccessToken { [weak self] (recred: OAuth2Credential?, error: Error?) in
                   
            guard let myself = self else { return }
            
            guard error == nil else {
                dlog("error refreshing accessToken: \(error!)")
                //probably should retry this w backoff strategy
                return
            }
            
            guard let _ = recred else { return }
            myself.handleRetrySend()
        }
    }
    
    func retry(urlRequest: URLRequest, error: ServiceError) -> Void {
        
        dlog("retry: \(String(describing: urlRequest.url)), error: \(error)")
        
        dlog("headers: \(String(describing: urlRequest.allHTTPHeaderFields)))")
        
        guard error.code == 401, let foundRequestId = urlRequest.value(forHTTPHeaderField: "requestId") else {
            dlog("not a 401 or no reqeustId header, bailing")
            return
        }
        urlRequestDict[foundRequestId] = (urlRequest, error)
        refreshAccessToken()
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
            let searchSecret = Secret(secretKey: SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred)
            var error: Error?
            var secret: Secret?
            secretService.fetchSecret(searchSecret) { (s: Secret?, e: Error?) in
                secret = s
                error = e
            }
            guard let foundSecret = secret, let cred = foundSecret.secretValue as? OAuth2Credential else {
                dlog("error fetching authToken: \(String(describing: error))")
                return nil
            }
            if cred.isExpired { //likely need to resend, but hard to stop it now
                retryContainer.insert(request)
            }
            localHeaders["Authorization"] = "Bearer \(cred.accessToken)"
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
