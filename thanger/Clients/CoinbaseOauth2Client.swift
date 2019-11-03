//
//  CoinbaseOauth2Client.swift
//  thanger
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class CoinbaseOauth2Client: CoinbaseHttpClient {
    

    override func buildUrl(withRequest request: RemoteRequest) -> URL? {
     
        /*
        request.params[Constants.theMovieDbApiKeyName] = Constants.theMovieDbApiKey
        if request.requiresSession, let sessionId = Constants.sessionId {
            request.params[Constants.theMovieDbSessionKeyName] = sessionId
        }
        */
        return super.buildUrl(withRequest: request)
    }
    
    override func buildUrlRequest(withRemoteRequest request: RemoteRequest) -> URLRequest? {
        
        var urlRequest: URLRequest?
        
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
                    headers["Content-Type"] = "application/json"
                }
                catch {
                    dlog(String(describing: error))
                }
                
            default:
                dlog("unsupported contentType: \(request.contentType)")
            }
        }
       
        if !headers.isEmpty {
            urlRequest?.allHTTPHeaderFields = headers
        }
                
        return urlRequest
    }
    
    @discardableResult //forward to transport
    override func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return transport.send(urlRequest: request, completion: completion)
    }
    
    
    override var description: String {
        return CoinbaseOauth2Client.staticName
    }
    
    override class var staticName: String {
        return "CoinbaseOauth2Client"
    }
}
