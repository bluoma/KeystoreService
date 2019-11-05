//
//  CoinbaseOauth2WebClient.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

//hits www.coinbase.com
class CoinbaseOauth2WebClient: CoinbaseOauth2Client {
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "CoinbaseOauth2WebClient"
    }
}
