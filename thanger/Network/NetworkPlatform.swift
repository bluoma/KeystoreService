//
//  NetworkPlatform.swift
//  thanger
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum BuildEnv: String {
    case dev = "dev"
    case qa = "qa"
    case prod = "prod"
}

class NetworkPlatform {
    
    fileprivate var remoteClients: [RemoteClient] = []
    fileprivate var requestClientDict: [String: RemoteClient] = [:]
    fileprivate var requestTaskDict: [RemoteRequest: Any] = [:]
    fileprivate let requestTaskDictLock = NSLock()
    fileprivate let secretService = SecretService()
    static var appPrefix: String = ""
    static var sharedKeychainService: String = ""
    static var sharedKeychainGroup: String = ""
    static var sharedAppGroup: String = ""
    
    fileprivate init() {
        let containers: (array: [RemoteClient], dict: [String: RemoteClient]) = Self.loadNetworkPlist(forEnv: Self.buildEnv)
        precondition(containers.array.count > 1, "no remote clients")
        precondition(!containers.dict.isEmpty, "no requst client mapping")
        remoteClients = containers.array
        requestClientDict = containers.dict
        dlog("remoteClients: \(remoteClients)")
        dlog("requestClientDict: \(requestClientDict)")
        guard let secretDict: [String: AnyObject] = Self.loadSecrets(),
        let clientId = secretDict["CoinbaseClientId"] as? String,
        let clientSecret = secretDict["CoinbaseClientSecret"] as? String else {
            assert(false, "bad secretDict")
            return
        }
        let storeStatus = storeSecrets(clientId: clientId, clientSecret: clientSecret)
        dlog("stored client strings status: \(storeStatus)")
        assert(storeStatus > 0, "error storing coinbase client strings")
    }
    
    static func load() {
        let _ = shared
    }
    
    static var shared: NetworkPlatform = NetworkPlatform()
    
    static var buildEnv: BuildEnv {
        #if DEBUG
        let env = BuildEnv.dev
        #elseif RELEASE
        let env = BuildEnv.prod
        #else
        let env = BuildEnv.qa
        #endif
        return env
    }
    
    
    fileprivate static func loadNetworkPlist(forEnv env: BuildEnv) -> ([RemoteClient], [String: RemoteClient]){
        
        var clients: [RemoteClient] = []
        var requestMap: [String: RemoteClient] = [:]
        
        let plistName: String
        
        switch env {
        case .dev:
            plistName = "Network"
        case .qa:
            plistName = "Network"
        case .prod:
            plistName = "Network"
        }
        
        let plistDict = readPropertyList(plistName)
        guard !plistDict.isEmpty else {
            dlog("Error no plistDict found")
            return (clients, requestMap)
        }
        
        guard let clientsArray = plistDict["remoteClients"] as? [[String: String]] else {
            return (clients, requestMap)
        }
        for clientDict in clientsArray {
            guard let clientName = clientDict["client"] else { continue }
            //create CoinbaseOauth2WebClient
            if clientName == CoinbaseOauth2WebClient.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for CoinbaseOauth2WebClient in plist")
                    continue
                }
                let client: CoinbaseOauth2WebClient
                if let port = clientDict["port"] {
                    client = CoinbaseOauth2WebClient(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = CoinbaseOauth2WebClient(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
            if clientName == CoinbaseOauth2Client.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for CoinbaseOauth2Client in plist")
                    continue
                }
                let client: CoinbaseOauth2Client
                if let port = clientDict["port"] {
                    client = CoinbaseOauth2Client(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = CoinbaseOauth2Client(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
            //create CoinbaseHttpClient
            if clientName == CoinbaseHttpClient.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for CoinbaseHttpClient in plist")
                    continue
                }
                let client: CoinbaseHttpClient
                if let port = clientDict["port"] {
                    client = CoinbaseHttpClient(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = CoinbaseHttpClient(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
            //create WSClient
            if clientName == WSClient.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for WSClient in plist")
                    continue
                }
                let client: WSClient
                if let port = clientDict["port"] {
                    client = WSClient(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = WSClient(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
        }
        
        guard let reqClientDict = plistDict["requestClientDict"] as? [String: String] else {
            return (clients, requestMap)
            
        }
        for (key, val) in reqClientDict {
            if let client = clients.first(where: { $0.description == val }) {
                requestMap[key] = client
            }
        }
        return (clients, requestMap)
    }
    
    fileprivate func storeSecrets(clientId: String, clientSecret: String) -> Int {
        var status = -1
        
             
        let clientIdSecret = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretType: .string, secretValue: clientId)
        
        let clientSecretSecret = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretType: .string, secretValue: clientSecret)
        
        secretService.storeSecret(clientIdSecret) { (secret: Secret?, error: Error?) in
            
            if let error = error {
                dlog("error storing clientId secret: \(error)")
                status = -2
            }
            else {
                dlog("stored clientId secret: \(String(describing: secret))")
                status = 2
            }
        }
        
        secretService.storeSecret(clientSecretSecret) { (secret: Secret?, error: Error?) in
            
            if let error = error {
                dlog("error storing clientSecret secret: \(error)")
                status = -3
            }
            else {
                dlog("stored clientSecret secret: \(String(describing: secret))")
                status = 3
            }
        }
        
        return status
    }
    
    fileprivate static func loadSecrets() -> [String: AnyObject]? {
        
        let secretsPlist = readPropertyList("secrets")
        dlog("secrets.plist: \(secretsPlist)")

        guard let coinbaseDict = secretsPlist["Coinbase"] as? [String: AnyObject],
            let _ = coinbaseDict["CoinbaseClientId"] as? String,
            let _ = coinbaseDict["CoinbaseClientSecret"] as? String else {
                dlog("error getting coinbase client strings")
                return nil
        }
        
        guard let mainAppDict = secretsPlist["MainApp"] as? [String: AnyObject],
            let appPrefix = mainAppDict["AppPrefix"] as? String,
            let sharedKeychainService = mainAppDict["SharedKeychainService"] as? String,
            let sharedKeychainGroup = mainAppDict["SharedKeychainGroup"] as? String,
            let sharedAppGroup = mainAppDict["SharedAppGroup"] as? String
        else {
                dlog("error getting coinbase client strings")
            return nil
        }
        
        Self.appPrefix = appPrefix
        Self.sharedKeychainService = sharedKeychainService
        Self.sharedKeychainGroup = sharedKeychainGroup
        Self.sharedAppGroup = sharedAppGroup
        
        return coinbaseDict
        
    }
    
    func clientForRequest(name: String) -> RemoteClient? {
        return requestClientDict[name]
    }
    
    func taskForRequest(_ request: RemoteRequest) -> Any? {
        requestTaskDictLock.lock()
        defer {
            requestTaskDictLock.unlock()
        }
        return requestTaskDict[request]
    }
    
    func addTask(_ task: Any, forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = task
        requestTaskDictLock.unlock()
    }
    
    func removeTask(forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = nil
        requestTaskDictLock.unlock()
    }
    
    func send(remoteRequest: RemoteRequest) -> Any? {
        
        guard let client = clientForRequest(name: remoteRequest.description) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidClient.rawValue, msg: "No client for request \(String(describing: self))")
            remoteRequest.failureBlock?(error)
            remoteRequest.blockCalled = true
            return nil
        }
        
        guard var urlRequest = client.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidRequest.rawValue, msg: "No urlRequest from client: \(String(describing: client))")
            remoteRequest.failureBlock?(error)
            remoteRequest.blockCalled = true
            return nil
        }
        
        urlRequest.setValue(remoteRequest.requestId, forHTTPHeaderField: "requestId")
        
        //send the urlRequest back to the service if it's not sendable by a client->transport
        //e.g it's for a webview or an external app to load
        guard remoteRequest.isTransportable else {
            return urlRequest
        }
        
        //forward to client 
        let task = client.send(urlRequest: urlRequest, completion: {
            [weak self] (data: Data?, headers: [AnyHashable: Any], error: Error?) in
            
            guard let myself = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    remoteRequest.failureBlock?(error)
                    remoteRequest.blockCalled = true
                }
            }
            else {
                DispatchQueue.main.async {
                    remoteRequest.successBlock?(data, headers)
                    remoteRequest.blockCalled = true
                }
            }
            myself.removeTask(forRequest: remoteRequest)
        })
        
        if let foundtask = task {
            addTask(foundtask, forRequest: remoteRequest)
        }
        return task
    }
}
