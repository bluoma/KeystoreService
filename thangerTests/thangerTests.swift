//
//  thangerTests.swift
//  thangerTests
//
//  Created by Bill on 10/29/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import XCTest

class thangerTests: XCTestCase {

    let secretService = SecretService()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }

    func testStoreAccessToken() {
        
        let secret = Secret(secretKey:SecretKeys.coinbaseAccessTokenKey, secretVal: "abcdefghijklmnopqrstuvwxyz", secretType: .accessToken)
        
        secretService.storeSecret(secret)
        { (secret: Secret?, error: Error?) in
            
            if let secret = secret {
                dlog("secret: \(secret)")
            }
            else if let error = error {
                dlog("error: \(error)")
                XCTFail("error")
            }
            else {
                XCTFail("no secret, no error")
            }
        }
    }

    
    func testFetchAccessToken() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseAccessTokenKey, secretVal: "", secretType: .accessToken)
        
        secretService.fetchSecret(searchSecret) { (secret: Secret?, error: Error?) in
            
            if let secret = secret {
                dlog("secret: \(secret)")
            }
            else if let error = error {
                dlog("error: \(error)")
                XCTFail("error")
            }
            else {
                XCTFail("no secret, no error")
            }
        }
    }
    
    func testDeleteAccessToken() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseAccessTokenKey, secretVal: "", secretType: .accessToken)
        
        secretService.deleteSecret(searchSecret) { (secret: Secret?, error: Error?) in
            
           if let error = error {
                dlog("error: \(error)")
                XCTFail("error")
            }
            else {
                dlog("success")
            }
        }
    }

    
    func testDeleteAllSecrets() {
                
        secretService.clearAllSecrets() { (secret: Secret?, error: Error?) in
            
           if let error = error {
                dlog("error: \(error)")
                XCTFail("error")
            }
            else {
                dlog("success")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
