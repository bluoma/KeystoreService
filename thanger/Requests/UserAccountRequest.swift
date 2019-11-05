//
//  UserAccountRequest.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAccountRequest: RemoteRequest {
    
    override init() {
        super.init()
        super.version = "/v2"
        super.resourcePath = "/?"
    }
    
    override var description: String {
        return Self.staticName
    }
    
    override class var staticName: String {
        return "UserAccountRequest"
    }
}
