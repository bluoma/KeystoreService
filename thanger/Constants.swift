//
//  Constants.swift
//  thanger
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


import Foundation

//global functions
//MARK: dlog
public func dlog(_ message: String, _ filePath: String = #file, _ functionName: String = #function, _ lineNum: Int = #line)
{
    #if DEBUG
        
        let url  = URL(fileURLWithPath: filePath)
        let path = url.lastPathComponent
        var fileName = "Unknown"
        if let name = path.split(separator: ",").map(String.init).first {
            fileName = name
        }
        let logString = String(format: "%@.%@[%d]: %@", fileName, functionName, lineNum, message)
        NSLog(logString)
        
    #endif
    
}

let appPrefix = "M96UWZCD49"
let sharedKeychainService = "M96UWZCD49.com.bluoma.thanger.shared.service"
let sharedKeychainGroup = "M96UWZCD49.com.bluoma.thanger.shared"
