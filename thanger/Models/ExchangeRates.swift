//
//  ExchangeRates.swift
//  thanger
//
//  Created by Bill on 11/1/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

/*
 {
   "data": {
     "currency": "BTC",
     "rates": {
       "AED": "36.73",
       "AFN": "589.50",
       "ALL": "1258.82",
       "AMD": "4769.49",
       "ANG": "17.88",
       "AOA": "1102.76",
       "ARS": "90.37",
       "AUD": "12.93",
       "AWG": "17.93",
       "AZN": "10.48",
       "BAM": "17.38",
       ...
     }
   }
 }
 
 */

struct ExchangeRates: Encodable, CustomStringConvertible {
    
    let currency: String
    let rates: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case currency
        case rates
    }
    
    var description: String {
        return "\(currency) \nrates: \(rates)"
    }
}

extension ExchangeRates: Decodable {
    
    enum DataKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DataKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        currency = try dataContainer.decode(String.self, forKey: .currency)
        rates = try dataContainer.decode([String: String].self, forKey: .rates)
    }
}
