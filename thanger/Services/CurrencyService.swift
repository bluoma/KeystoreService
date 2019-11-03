//
//  CurrencyService.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class CurrencyService {
    
    func getFiatCurrencies(completion: @escaping ([FiatCurrency], Error?) -> Void) {
        
        let request = CurrencyRequest.fetchFiatCurrenciesRequest()
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let currencyResult: FiatCurrencyResult = try decoder.decode(FiatCurrencyResult.self, from: foundData)
                    completion(currencyResult.currencies, nil)
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
    
    func getDigitalAssets(completion: @escaping ([DigitalAsset], Error?) -> Void) {
        
        let request = CurrencyRequest.fetchDigitalCurrenciesRequest()
        request.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let currencyResult: DigitalAssetResult = try decoder.decode(DigitalAssetResult.self, from: foundData)
                    completion(currencyResult.assets, nil)
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
