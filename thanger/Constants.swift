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

public func readPropertyList(_ filename: String) -> [String: AnyObject] {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    var plistDict: [String: AnyObject] = [:]
    guard let plistPath: String = Bundle.main.path(forResource: filename, ofType: "plist"),
        let plistXML = FileManager.default.contents(atPath: plistPath) else {
            dlog("Error reading plist: \(filename)")
        return plistDict
    }
    
    do {
        if let plistObj = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String:AnyObject] {
            plistDict = plistObj
        }

    } catch {
        dlog("Error reading plist: \(error)")
    }
    return plistDict
}

let appPrefix = "M96UWZCD49"
let sharedKeychainService = "M96UWZCD49.com.bluoma.thanger.shared.service"
let sharedKeychainGroup = "M96UWZCD49.com.bluoma.thanger.shared"
let sharedAppGroup = "group.com.bluoma.thanger"
let oauthRedirectNotification = "oauthRedirectNotification"
let oauth2RedirectUri = "thanger://com.bluoma.thanger/oauth/redir"
