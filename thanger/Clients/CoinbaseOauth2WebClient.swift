//
//  CoinbaseOauth2WebClient.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class CoinbaseOauth2WebClient: RemoteClient {
    
    
    override func buildUrlRequest(withRemoteRequest request: RemoteRequest) -> URLRequest? {
        
        guard let url = buildUrl(withRequest: request) else { return nil }
            
        var theUrlRequest = URLRequest(url: url)
        theUrlRequest.httpMethod = request.method
        if !headers.isEmpty {
            theUrlRequest.allHTTPHeaderFields = headers
        }
        return theUrlRequest
    }
 
    @discardableResult //no sending via transport
    override func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return nil
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "CoinbaseOauth2WebClient"
    }
}
