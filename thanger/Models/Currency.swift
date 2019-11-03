//
//  Currency.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

/*
 {
   "id": "AED",
   "name": "United Arab Emirates Dirham",
   "min_size": "0.01000000"
 }
 
*/

protocol Currency {
    var id: String { get }
    var name: String { get }
}

struct DigitalCurrency: Currency, Codable, CustomStringConvertible {

    let id: String
    let name: String
    
    static func pairString(c1: Currency, c2: Currency) -> String {
        return "\(c1.id)-\(c2.id)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    var description: String {
        return "\(id):\(name)"
    }
}

struct FiatCurrency: Currency, Codable, CustomStringConvertible {
    
    let id: String
    let name: String
    let minSize: String
    
    
    static func pairString(c1: Currency, c2: Currency) -> String {
        return "\(c1.id)-\(c2.id)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case minSize = "min_size"
    }
    
    var description: String {
        return "\(id):\(name):\(minSize)"
    }
}

struct FiatCurrencyResult: Codable {
    
    let currencies: [FiatCurrency]
    
    enum CodingKeys: String, CodingKey {
        case currencies = "data"
    }
}

