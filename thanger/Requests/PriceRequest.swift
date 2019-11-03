//
//  PriceRequest.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

enum PriceType: String {
    case buy = "buy"
    case sell = "sell"
    case spot = "spot"
}

class PriceRequest: RemoteRequest {
    
    override init() {
        super.init()
        super.version = "/v2"
        super.resourcePath = "/prices"
    }
    
    class func fetchPriceRequest(forType type: PriceType, c1: Currency) -> PriceRequest {
        
        let request = PriceRequest()
        request.method = HTTPMethod.get.rawValue
        request.appendPath(c1.id)
        request.appendPath(type.rawValue)
        
        return request
    }
    
    class func fetchPriceRequest(forType type: PriceType, c1: DigitalCurrency, c2: FiatCurrency) -> PriceRequest {
        
        let request = PriceRequest()
        request.method = HTTPMethod.get.rawValue
        let subPath = DigitalCurrency.pairString(c1: c1, c2: c2)
        request.appendPath(subPath)
        request.appendPath(type.rawValue)
        
        return request
    }
    
    class func fetchSpotPriceRequest(c1: DigitalCurrency, c2: FiatCurrency, date: Date?) -> PriceRequest {
        
        let request = PriceRequest()
        request.method = HTTPMethod.get.rawValue
        let subPath = DigitalCurrency.pairString(c1: c1, c2: c2)
        request.appendPath(subPath)
        request.appendPath(PriceType.spot.rawValue)
        
        return request
    }
    
    class func fetchSpotPriceListRequest(c1: FiatCurrency, date: Date?) -> PriceRequest {
        
        let request = PriceRequest()
        request.method = HTTPMethod.get.rawValue
        request.appendPath(c1.id)
        request.appendPath(PriceType.spot.rawValue)
        
        return request
    }
    
    class func fetchDigitalAssetPriceSummaryRequest(c1: FiatCurrency, resolution: String, includePrices: Bool = false) -> PriceRequest {
        
        let request = PriceRequest()
        request.method = HTTPMethod.get.rawValue
        request.resourcePath = "/assets/summary"
        request.params["resolution"] = resolution
        request.params["include_prices"] = String(includePrices)
        
        return request
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "PriceRequest"
    }
    
}
