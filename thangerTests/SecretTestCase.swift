//
//  SecretTestCase.swift
//  thanger
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import XCTest

class SecretTestCase: XCTestCase {

    var mainPlist: [String: Any] = Bundle.main.infoDictionary!
    var testBundle: Bundle!
    var testPlist: [String: Any]!
    let userAccountKey = "detectAppIdentifierForKeyChainGroupIdUsage"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        testBundle = Bundle(for: type(of: self))
        if let testPlist = testBundle.infoDictionary {
            self.testPlist = testPlist
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func statusMessageForKeyChain(status: OSStatus) -> String {
        let resultString: String
        
        if let message = SecCopyErrorMessageString(status, nil) as String? {
            resultString = message
        }
        else {
            resultString = ""
        }
       
        return resultString
    }

    func testRetreiveKeyChainGroupId() {
        
        if let appIdentifierPrefix = testPlist["AppIdentifierPrefix"] as? String {
            dlog("appIdentifierPrefix: \(appIdentifierPrefix)")
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: userAccountKey,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
                kSecReturnAttributes as String: kCFBooleanTrue as Any
            ]
            
            var queryResult: AnyObject?
            var status = withUnsafeMutablePointer(to: &queryResult) {
              SecItemCopyMatching(query as CFDictionary, $0)
            }
            
            let errMsgRetVal = statusMessageForKeyChain(status: status)
            dlog("status for first lookup: \(status), errMsgRetVal: \(errMsgRetVal as String?)")
            
            switch status {
                
            case errSecItemNotFound:
                status = SecItemAdd(query as CFDictionary, nil)
                if status != errSecSuccess {
                    XCTFail("error calling SecItemAdd: \(status), \(statusMessageForKeyChain(status: status))")
                    return
                }
                status = withUnsafeMutablePointer(to: &queryResult) {
                    SecItemCopyMatching(query as CFDictionary, $0)
                }
                if status != errSecSuccess {
                    XCTFail("error calling SecItemCopyMatching bis: \(status), \(statusMessageForKeyChain(status: status))")
                    return
                }
                
            default:
                dlog("status \(status), \(errMsgRetVal)")
            }
            
            dlog("queryResult bis: \(String(describing: queryResult))")
            
            if let queryDict = queryResult as? [AnyHashable: Any],
                let accessGroup = queryDict[(kSecAttrAccessGroup as String)] as? String {
                dlog("accessGroup: \(accessGroup)")
            }
            else {
                XCTFail("No accessGroup")
            }
        }
        else {
            dlog("\(String(describing: testPlist))")
            XCTFail("No appIdentifierPrefix")
        }
    }
    
    func testRemoveKeyChainGroupId() {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userAccountKey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
            
        case errSecSuccess:
            dlog("deleted groupIdAccountKey: \(userAccountKey)")
            
        case errSecItemNotFound:
            dlog("groupIdAccountKey: \(userAccountKey) not found")
            
        default:
            let errMsgRetVal = statusMessageForKeyChain(status: status)
            XCTFail("error \(status), \(errMsgRetVal)")
        }
    }
    
    
    func testEncodeDecodeSecret() {
        
        let secret = Secret(secretKey: SecretKeys.coinbaseAccessTokenKey, secretVal: "0123456789", secretType: .accessToken, expirationDate: nil)
        
        let encoder = JSONEncoder()
        //encoder.dateEncodingStrategy = .secondsSince1970
        
        do {
        let jsonData = try encoder.encode(secret)
            dlog("jsonObj: \(type(of: jsonData))")
            dlog("for secret: \(secret)")
        }
        catch {
            dlog("encoding error: \(error)")
            XCTFail("\(error.localizedDescription)")
        }
        
        let jsonString = """
        {
          "access_token":"0123456789",
          "token_type":"bearer",
          "expires_in":7200,
          "refresh_token":"9876543210",
          "scope":"all"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("error serializing string: \(jsonString)")
            return
        }
        
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
                dlog("\(jsonObj)")
                
                guard let accessToken = jsonObj["access_token"] as? String else {
                    XCTFail("error getting access_token from jsonObj: \(jsonObj)")
                    return
                }
                let accessTokenSecret = Secret(secretKey: SecretKeys.coinbaseAccessTokenKey, secretVal: accessToken, secretType: .accessToken)
                dlog("accessTokenSecret: \(accessTokenSecret)")
                
                guard let refreshToken = jsonObj["refresh_token"] as? String else {
                    XCTFail("error getting refresh_token from jsonObj: \(jsonObj)")
                    return
                }
                
                let refreshTokenSecret = Secret(secretKey: SecretKeys.coinbaseRefreshTokenKey, secretVal: refreshToken, secretType: .refreshToken)
                dlog("refreshTokenSecret: \(refreshTokenSecret)")
                
            }
            else {
                XCTFail("error serializing data: \(jsonData) not at dict")
            }
            
        }
        catch {
            XCTFail("error serializing data: \(jsonData), error: \(error)")
        }
        
    }
    
    
    func testStoreAccessToken() {
        
        let secret = Secret(secretKey: SecretKeys.coinbaseAccessTokenKey, secretVal: "0123456789", secretType: .accessToken, expirationDate: nil)
        
        dlog("secret: \(secret)")
        let encoder = JSONEncoder()
        //encoder.dateEncodingStrategy = .secondsSince1970
        
        var jsonSecret: Data = Data()
        
        do {
            let jsonData = try encoder.encode(secret)
            dlog("jsonObj: \(type(of: jsonData))")
            dlog("for secret: \(secret)")
            jsonSecret = jsonData
        }
        catch {
            dlog("encoding error: \(error)")
            XCTFail("\(error.localizedDescription)")
        }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: secret.secretKey,
            kSecAttrService as String: sharedKeychainService,
            kSecAttrAccessGroup as String: sharedKeychainGroup,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnAttributes as String: kCFBooleanFalse as Any
        ]
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        
        let errMsgRetVal = statusMessageForKeyChain(status: status)
        dlog("status for first lookup: \(status), errMsgRetVal: \(errMsgRetVal as String?)")
        
        switch status {
            
        case errSecItemNotFound:
            query[kSecValueData as String] = jsonSecret
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                XCTFail("error calling SecItemAdd: \(status), \(statusMessageForKeyChain(status: status))")
                return
            }
            else {
                dlog("stored new secret in keychain: \(secret)")
            }
            
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[kSecValueData as String] = jsonSecret
            dlog("found existing secret in keychain, need to update")
            status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                XCTFail("error calling SecItemUpdate: \(status), \(statusMessageForKeyChain(status: status))")
            }
            else {
                dlog("updated new secret in keychain: \(secret)")
            }
            
        default:
            XCTFail("error \(status), \(errMsgRetVal)")
        }
        
    }
    

    func testRetrieveAccessTokenSecret() {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SecretKeys.coinbaseAccessTokenKey,
            kSecAttrService as String: sharedKeychainService,
            kSecAttrAccessGroup as String: sharedKeychainGroup,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecReturnAttributes as String: kCFBooleanTrue as Any,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
          SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        
        let errMsgRetVal = statusMessageForKeyChain(status: status)
        dlog("status for first lookup: \(status), errMsgRetVal: \(errMsgRetVal as String?)")
        
        if status == errSecSuccess {
            
            guard let queriedItem = queryResult as? [String: Any],
                let secretData = queriedItem[kSecValueData as String] as? Data else {
                    XCTFail("error getting data from resultDict")
                    return
            }
            do {
                let decoder = JSONDecoder()
                let accessTokenSecret = try decoder.decode(Secret.self, from: secretData)
                dlog("accessTokenSecret: \(accessTokenSecret)")
            }
            catch {
                XCTFail("error parsing data from resultDict: \(error)")
            }
        }
    }
    
    func testRemoveAccessTokenSecret() {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: SecretKeys.coinbaseAccessTokenKey,
            kSecAttrService as String: sharedKeychainService,
            kSecAttrAccessGroup as String: sharedKeychainGroup,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
            
        case errSecSuccess:
            dlog("deleted SecretKeys.coinbaseAccessTokenKey: \(SecretKeys.coinbaseAccessTokenKey)")
            
        case errSecItemNotFound:
            dlog("SecretKeys.coinbaseAccessTokenKeyy: \(SecretKeys.coinbaseAccessTokenKey) not found")
            
        default:
            let errMsgRetVal = statusMessageForKeyChain(status: status)
            XCTFail("error \(status), \(errMsgRetVal)")
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
