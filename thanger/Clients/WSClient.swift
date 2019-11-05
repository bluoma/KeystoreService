//
//  WebSocketClient.swift
//  MoreClients
//
//  Created by Bill on 10/23/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


/*
 // Request
 // Subscribe to ETH-USD and ETH-EUR with the level2, heartbeat and ticker channels,
 // plus receive the ticker entries for ETH-BTC and ETH-USD
 {
     "type": "subscribe",
     "product_ids": [
         "ETH-USD",
         "ETH-EUR"
     ],
     "channels": [
         "level2",
         "heartbeat",
         {
             "name": "ticker",
             "product_ids": [
                 "ETH-BTC",
                 "ETH-USD"
             ]
         }
     ]
 }
 // Response
 {
     "type": "subscriptions",
     "channels": [
         {
             "name": "level2",
             "product_ids": [
                 "ETH-USD",
                 "ETH-EUR"
             ],
         },
         {
             "name": "heartbeat",
             "product_ids": [
                 "ETH-USD",
                 "ETH-EUR"
             ],
         },
         {
             "name": "ticker",
             "product_ids": [
                 "ETH-USD",
                 "ETH-EUR",
                 "ETH-BTC"
             ]
         }
     ]
 }
 
 */


class WSClient: RemoteClient {
    
    lazy var transport: RemoteTransport = {
        var wsTransport: RemoteTransport
        if #available(iOS 13, *) {
            wsTransport = WSNativeTransport(withBaseUrl: buildBaseUrl()!)
            wsTransport.connectBlock = wsTransportDidConnect
            wsTransport.disconnectBlock = wsTransportDidDisconnect(error:)
        }
        else {
            wsTransport = WSStarscreamTransport(withBaseUrl: buildBaseUrl()!)
            wsTransport.connectBlock = wsTransportDidConnect
            wsTransport.disconnectBlock = wsTransportDidDisconnect(error:)
        }
        return wsTransport
    } ()
    
    
    init() {
        super.init(withScheme: "ws", host: "localhost", port: "9704")
        //transport.connect()
    }
    
    override init(withScheme scheme: String, host: String, port: String = "") {
        super.init(withScheme: scheme, host: host, port: port)
        //transport.connect()
    }
    
    override func buildUrl(withRequest request: RemoteRequest) -> URL? {
        
        var url: URL? = nil
        
        var components: URLComponents = URLComponents()
        if !scheme.isEmpty {
            components.scheme = scheme
        }
        if !host.isEmpty {
            components.host = host
        }
        if !port.isEmpty {
            components.port = Int(port)
        }
        if !request.fullPath.isEmpty {
            components.path = request.fullPath
        }
        if !request.params.isEmpty {
            
            var items: [URLQueryItem] = []
            for (name, value) in request.params {
                let percentEncodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let item: URLQueryItem = URLQueryItem(name: name, value: percentEncodedValue)
                items.append(item)
            }
            components.queryItems = items
        }
        
        url = components.url
        dlog("url: \(String(describing: url))")
        
        return url
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
    
    fileprivate func wsTransportDidConnect() {
        dlog("")
    }
    
    fileprivate func wsTransportDidDisconnect(error: Error?) {
        dlog("error: \(error?.localizedDescription ?? "no error")...")
        //TODO backoff strategy to reconnect
        //wsTransport.connect()
    }
    
    @discardableResult //forward to transport
    override func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return transport.send(urlRequest: request, completion: completion)
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "WSClient"
    }
}


