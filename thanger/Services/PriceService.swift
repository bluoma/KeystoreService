//
//  PriceService.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class PriceService {
    
    func getBuyPrice(forDigital c1: DigitalCurrency, inFiat c2: FiatCurrency, completion: @escaping (Price?, Error?) -> Void) {
        
        let request = PriceRequest.fetchPriceRequest(forType: .buy, c1: c1, c2: c2)
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let price: PricePair = try decoder.decode(PricePair.self, from: foundData)
                    completion(price, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                completion(nil, nil)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        request.send()
    }
    
    func getSellPrice(forDigital c1: DigitalCurrency, inFiat c2: FiatCurrency, completion: @escaping (Price?, Error?) -> Void) {
        
        let request = PriceRequest.fetchPriceRequest(forType: .sell, c1: c1, c2: c2)
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let price: PricePair = try decoder.decode(PricePair.self, from: foundData)
                    completion(price, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                completion(nil, nil)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        request.send()
    }
    
    func getSpotPrice(forDigital c1: DigitalCurrency, inFiat c2: FiatCurrency, date: Date?, completion: @escaping (Price?, Error?) -> Void) {
        
        let request = PriceRequest.fetchSpotPriceRequest(c1: c1, c2: c2, date: date)
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let price: PricePair = try decoder.decode(PricePair.self, from: foundData)
                    completion(price, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                completion(nil, nil)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion(nil, error)
        }
        request.send()
    }
    
    func getSpotPrices(forFiat c1: FiatCurrency, date: Date?, completion: @escaping ([Price], Error?) -> Void) {
        
        let request = PriceRequest.fetchSpotPriceListRequest(c1: c1, date: date)
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let priceResult: PriceResult = try decoder.decode(PriceResult.self, from: foundData)
                    completion(priceResult.prices, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion([], serviceError)
                }
            }
            else {
                completion([], nil)
            }
            
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion([], error)
        }
        request.send()
        
    }
    
    func getDigitalAssetPriceSummaries(forFiat c1: FiatCurrency, resolution: String, includePrices: Bool = false, completion: @escaping ([DigitalAssetPriceSummary], Error?) -> Void) {
        
        let request = PriceRequest.fetchDigitalAssetPriceSummaryRequest(c1: c1, resolution: resolution, includePrices: includePrices)
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let priceResult: DigitalAssetPriceSummaryResult = try decoder.decode(DigitalAssetPriceSummaryResult.self, from: foundData)
                    completion(priceResult.priceSummaries, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion([], serviceError)
                }
            }
            else {
                completion([], nil)
            }
        }
        request.failureBlock = { (error: Error?) -> Void in
            completion([], error)
        }
        request.send()
        
    }
}
