//
//  RequestProtocol.swift
//  thanger
//
//  Created by Bill on 11/3/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


protocol RequestProtocol {
    
    var isTransportable: Bool { get set }
    
    func send() -> Any?
    
}
