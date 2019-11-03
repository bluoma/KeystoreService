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
     
        
        if request.requiresSession {
            //add oauth access token to Authorization header
        }
        
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
            case "application/x-www-form-urlencoded":
                var bodyArray: [String] = []
                for (key, val) in request.contentBody {
                    let keyVal = "\(key)=\(val)"
                    bodyArray.append(keyVal)
                }
                var bodyString = bodyArray.joined(separator: "&")
                dlog("bodyStringNotEncoded: \(bodyString)")
                var allowed = CharacterSet.alphanumerics
                allowed.insert(charactersIn: "-._~") // as per RFC 3986
                if let percentEncoded = bodyString.addingPercentEncoding(withAllowedCharacters: allowed) {
                    bodyString = percentEncoded
                }
                dlog("bodyStringEncoded: \(bodyString)")
                if let data = bodyString.data(using: .utf8) {
                    theUrlRequest.httpBody = data
                    urlRequest = theUrlRequest
                    headers["Content-Type"] = "application/x-www-form-urlencoded"
                }
                else {
                    assert(false, "bad post body: \(bodyString)")
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
        return Self.staticName
    }
    
    override class var staticName: String {
        return "CoinbaseOauth2Client"
    }
}
