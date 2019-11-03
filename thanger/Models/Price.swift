//
//  Price.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

/*
 https://api.coinbase.com/v2/prices/LTC-USD/spot
 {
   "data": {
     "base": "LTC",
     "amount": "1020.25",
     "currency": "USD"
   }
 }
 
 https://api.coinbase.com/v2/prices/USD/spot
 {
     "data": [{
             "base": "BTC",
             "currency": "USD",
             "amount": "9340.945"
         },
         {
             "base": "EUR",
             "currency": "USD",
             "amount": "1.12"
         }
     ]
 }
 */


struct PriceResult: Codable {
    
    let prices: [PriceElement]
    
    enum CodingKeys: String, CodingKey {
        case prices = "data"
    }
    
}

protocol Price {
    var base: String { get }
    var currency: String { get }
    var amount: String { get }
}

struct PriceElement: Price, Codable, CustomStringConvertible {
    
    let base: String       //usually digial
    let currency: String   //fiat
    let amount: String
        
    var description: String {
        return "\(base): \(amount) \(currency)"
    }
}


struct PricePair: Price, CustomStringConvertible {
    
    let base: String       //usually digial
    let currency: String   //fiat
    let amount: String
        
    var description: String {
        return "\(base): \(amount) \(currency)"
    }
}

extension PricePair: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case base
        case currency
        case amount
    }
}

extension PricePair: Decodable {

    enum DataKeys: String, CodingKey {
        case data
    }

    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataKeys.self)
        let priceContainer = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        base = try priceContainer.decode(String.self, forKey: .base)
        currency = try priceContainer.decode(String.self, forKey: .currency)
        amount = try priceContainer.decode(String.self, forKey: .amount)
    }
    
}


struct DigitalAssetPriceSummary: Codable, CustomStringConvertible {
    
    let id: String
    let base: String
    let name: String
    let currency: String
    let unitPriceScale: Int
    let marketCap: String
    let percentChange: Double
    let latest: String
    let prices: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, base, name, currency, latest, prices
        case unitPriceScale = "unit_price_scale"
        case marketCap = "market_cap"
        case percentChange = "percent_change"
    }
    
    var description: String {
        return "\(id):\(base):\(name):\(latest) \(currency)"
    }
}

struct DigitalAssetPriceSummaryResult: Codable {
    let priceSummaries: [DigitalAssetPriceSummary]
    
    enum CodingKeys: String, CodingKey {
        case priceSummaries = "data"
    }
}
