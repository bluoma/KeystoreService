//
//  RemoteClient.swift
//  thanger
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class RemoteClient: CustomStringConvertible {
    
    var scheme: String = ""
    var host: String = ""
    var port: String = ""
    var headers: [String: String] = [:]
    
    init(withScheme scheme: String, host: String, port: String = "") {
        self.scheme = scheme
        self.host = host
        self.port = port
    }
    
    func buildBaseUrl() -> URL? {
        var url: URL? = nil
        
        var components: URLComponents = URLComponents()
        if !scheme.isEmpty {
            components.scheme = scheme
        }
        if !host.isEmpty {
            components.host = host
        }
        if !port.isEmpty, let foundPort = Int(port) {
            components.port = foundPort
        }
        url = components.url
        
        return url
    }
    
    func buildUrl(withRequest request: RemoteRequest) -> URL? {
        
        var url: URL? = nil
        
        var components: URLComponents = URLComponents()
        if !scheme.isEmpty {
            components.scheme = scheme
        }
        if !host.isEmpty {
            components.host = host
        }
        if !port.isEmpty, let foundPort = Int(port) {
            components.port = foundPort
        }
        if !request.fullPath.isEmpty {
            components.path = request.fullPath
        }
        if !request.params.isEmpty {
            
            var items: [URLQueryItem] = []
            for (name, value) in request.params {
                let item: URLQueryItem = URLQueryItem(name: name, value: value)
                items.append(item)
            }
            components.queryItems = items
        }
    
        url = components.url
        dlog("url: \(String(describing: url))")
        
        return url
    }
    
    func buildUrlRequest(withRemoteRequest request: RemoteRequest) -> URLRequest? {
        return nil
    }
    
    @discardableResult
    func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return nil
    }
    
    var description: String {
        return Self.staticName
    }
    
    class var staticName: String {
        return "RemoteClient"
    }
    
}
