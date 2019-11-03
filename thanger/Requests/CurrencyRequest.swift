//
//  CurrencyRequest.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class CurrencyRequest: RemoteRequest {
    
    override init() {
        super.init()
        super.version = "/v2"
        super.resourcePath = "/currencies"
    }
    
    class func fetchFiatCurrenciesRequest() -> CurrencyRequest {
        
        let request = CurrencyRequest()
        request.method = HTTPMethod.get.rawValue
        
        return request
    }
    
    class func fetchDigitalCurrenciesRequest() -> CurrencyRequest {
        
        let request = CurrencyRequest()
        request.method = HTTPMethod.get.rawValue
        request.resourcePath = "/assets/info"
        request.params["filter"] = "listed"
        request.params["locale"] = "en"
        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "CurrencyRequest"
    }
    
    
}
