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
        NetworkPlatform.load()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    func testStoreOauthCred() {
        let jsonString = """
        {
            "scope": "wallet:user:read wallet:accounts:read",
            "token_type": "bearer",
            "created_at": 1572898447,
            "refresh_token": "2c6b738293d6df954eaa4d2da998995efb2e687be9d23b943c3e4f789fc1d597",
            "expires_in": 7200,
            "access_token": "3b973ecd30f405589f5c1e613d7d7da854b220baa601fce5915a39f9f124042b"
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            
            do {
                let decoder = JSONDecoder()

                let cred = try decoder.decode(OAuth2Credential.self, from: data)
                dlog("cred: \(cred)")

                let key = SecretKeys.coinbaseOAuthCredentialKey
                let secret: Secret = Secret(secretKey: key, secretType: .oauthCred, secretValue: cred)
                
                secretService.storeSecret(secret)
                { (secret: Secret?, error: Error?) in
                    if let secret = secret {
                        dlog("secret: \(secret)")
                        if let cred = secret.secretValue as? OAuth2Credential {
                            dlog("cred: \(cred)")
                        }
                        else {
                            XCTFail("no cred")
                        }
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
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
    }
    
    
    func testFetchOAuthCred() {
           
           let searchSecret = Secret(secretKey:SecretKeys.coinbaseOAuthCredentialKey, secretType: .oauthCred)
           
           secretService.fetchSecret(searchSecret) { (secret: Secret?, error: Error?) in
               
               if let secret = secret {
                   dlog("secret: \(secret)")
                   if let cred = secret.secretValue as? OAuth2Credential {
                       dlog("cred: \(cred)")
                   }
                   else {
                       XCTFail("no cred")
                   }
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
    
    
    func testStoreClientId() {
        
        let secret = Secret(secretKey:SecretKeys.coinbaseClientIdKey, secretType: .string, secretValue: "12134567890")
        
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

    
    func testFetchClientId() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseClientIdKey, secretType: .string)
        
        secretService.fetchSecret(searchSecret) { (secret: Secret?, error: Error?) in
            
            if let secret = secret {
                dlog("secret: \(secret)")
                if let clientId = secret.secretValue as? String {
                    dlog("clientId: \(clientId)")
                }
                else {
                    XCTFail("no client id")
                }
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
    
    func testDeleteClientId() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseClientIdKey, secretType: .string)
        
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
    
    func testStoreClientSecret() {
        
        let secret = Secret(secretKey:SecretKeys.coinbaseClientSecretKey, secretType: .string, secretValue: "12134567890")
        
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

    func testFetchClientSecret() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseClientSecretKey, secretType: .string)
        
        secretService.fetchSecret(searchSecret) { (secret: Secret?, error: Error?) in
            
            if let secret = secret {
                dlog("secret: \(secret)")
                if let clientSecret = secret.secretValue as? String {
                    dlog("clientSecret: \(clientSecret)")
                }
                else {
                    XCTFail("no client secret")
                }
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
    
    func testDeleteClientSecret() {
        
        let searchSecret = Secret(secretKey:SecretKeys.coinbaseClientSecretKey, secretType: .string)
        
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
    
    func testSecretBis() {
        
        let jsonString = """
        {
            "scope": "wallet:user:read wallet:accounts:read",
            "token_type": "bearer",
            "created_at": 1572898447,
            "refresh_token": "2c6b738293d6df954eaa4d2da998995efb2e687be9d23b943c3e4f789fc1d597",
            "expires_in": 7200,
            "access_token": "3b973ecd30f405589f5c1e613d7d7da854b220baa601fce5915a39f9f124042b"
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let cred = try decoder.decode(OAuth2Credential.self, from: data)
                dlog("cred: \(cred)")

                let key = SecretKeys.coinbaseOAuthCredentialKey
                
                let secret: SecretBis<OAuth2Credential> = SecretBis(secretKey: key, secretType: .oauthCred, secretValue: cred)
                
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(secret)
                
                let ddecoder = JSONDecoder()
                let dsecret = try ddecoder.decode(SecretBis<OAuth2Credential>.self, from: jsonData)
                
                dlog("edsecret: \(dsecret)")
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
        
    }
    
    func testSecretTest() {
        
        let jsonString = """
        {
            "scope": "wallet:user:read wallet:accounts:read",
            "token_type": "bearer",
            "created_at": 1572898447,
            "refresh_token": "2c6b738293d6df954eaa4d2da998995efb2e687be9d23b943c3e4f789fc1d597",
            "expires_in": 7200,
            "access_token": "3b973ecd30f405589f5c1e613d7d7da854b220baa601fce5915a39f9f124042b"
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            
            do {
                let decoder = JSONDecoder()

                let cred = try decoder.decode(OAuth2Credential.self, from: data)
                dlog("cred: \(cred)")

                let key = SecretKeys.coinbaseOAuthCredentialKey
                let secret: Secret = Secret(secretKey: key, secretType: .oauthCred, secretValue: cred)
                
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(secret)
                
                let ddecoder = JSONDecoder()
                let dsecret = try ddecoder.decode(Secret.self, from: jsonData)
                
                dlog("edsecret: \(dsecret)")
               
                if let foundCred = dsecret.secretValue as? OAuth2Credential {
                    dlog("foundcred: \(foundCred)")
                }
                else {
                    XCTFail("no found cred from dsecret")
                }
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
        
    }
    
    func testDecodeOAuthCredential() {
        
        let jsonString = """
        {
            "scope": "wallet:user:read wallet:accounts:read",
            "token_type": "bearer",
            "created_at": 1572898447,
            "refresh_token": "2c6b738293d6df954eaa4d2da998995efb2e687be9d23b943c3e4f789fc1d597",
            "expires_in": 7200,
            "access_token": "3b973ecd30f405589f5c1e613d7d7da854b220baa601fce5915a39f9f124042b"
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let cred = try decoder.decode(OAuth2Credential.self, from: data)
                dlog("cred: \(cred)")
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
    }
    
    func testDecodeExchangeRates() {
        
        let jsonString = """
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
              "BAM": "17.38"
            }
          }
        }
        """
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let xrates = try decoder.decode(ExchangeRates.self, from: data)
                dlog("rates: \(xrates)")
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
    }

    func testDecodeCurrencies() {
        
        let jsonString = """
        {
          "data": [
            {
              "id": "AED",
              "name": "United Arab Emirates Dirham",
              "min_size": "0.01000000"
            },
            {
              "id": "AFN",
              "name": "Afghan Afghani",
              "min_size": "0.01000000"
            },
            {
              "id": "ALL",
              "name": "Albanian Lek",
              "min_size": "0.01000000"
            },
            {
              "id": "AMD",
              "name": "Armenian Dram",
              "min_size": "0.01000000"
            }
          ]
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let currencies = try decoder.decode(FiatCurrencyResult.self, from: data)
                dlog("currencies: \(currencies)")
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
    }
    
    func testDecodePrice() {
        
        let jsonString = """
        {
          "data": {
            "base": "BTC",
            "amount": "1020.25",
            "currency": "USD"
          }
        }
        """
        
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let price = try decoder.decode(PricePair.self, from: data)
                dlog("price: \(price)")
            }
            catch {
                dlog("error: \(error)")
                XCTFail("decoder error: \(error)")
            }
        }
        else {
            XCTFail("bad data from string")
        }
    }
    
    func testFetchPrice() {
        
        let service = PriceService()
        let exp = expectation(description: "load price")
        
        let c1 = DigitalCurrency(id: "DAI", name: "")
        let c2 = FiatCurrency(id: "USD", name: "", minSize: "")
        
        service.getBuyPrice(forDigital: c1, inFiat: c2) { (price: Price?, error: Error?) in
            
            if let error = error {
                dlog("\(error)")
                XCTFail("error getting price")
            }
            else {
                dlog("success price: \(String(describing: price))")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testFetchCurrencies() {
        
        let service = CurrencyService()
        let exp = expectation(description: "load currencies")
        
        
        service.getFiatCurrencies() { (currencies: [FiatCurrency], error: Error?) in
            
            if let error = error {
                dlog("\(error)")
                XCTFail("error getting currencies")
            }
            else {
                dlog("success currencies count: \(currencies.count)")
                for c in currencies {
                   print("\(c)")
                }
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testFetchDigtialcurrencies() {
        
        let service = CurrencyService()
        let exp = expectation(description: "load currencies")
        
        
        service.getDigitalAssets() { (currencies: [DigitalAsset], error: Error?) in
            
            if let error = error {
                dlog("\(error)")
                XCTFail("error getting currencies")
            }
            else {
                dlog("success currencies count: \(currencies.count)")
                for c in currencies {
                   print("\(c)")
                }
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    
    func testFetchPricesForDigitalCurrency() {
        
        let service = PriceService()
        let exp = expectation(description: "load prices")
        
        let c1 = FiatCurrency(id: "USD", name: "", minSize: "")

        service.getSpotPrices(forFiat: c1, date: nil) { (prices: [Price], error: Error?) in
            
            if let error = error {
                dlog("\(error)")
                XCTFail("error getting prices")
            }
            else {
                dlog("success prices count: \(prices.count)")
                for p in prices {
                   print("\(p)")
                }
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testFetchDigitalPriceSummaries() {
        
        let service = PriceService()
        let exp = expectation(description: "load prices")
        
        let c1 = FiatCurrency(id: "USD", name: "", minSize: "")

        service.getDigitalAssetPriceSummaries(forFiat: c1, resolution: "day", includePrices: true) { (prices: [DigitalAssetPriceSummary], error: Error?) in
            
            if let error = error {
                dlog("\(error)")
                XCTFail("error getting prices")
            }
            else {
                dlog("success prices count: \(prices.count)")
                for p in prices {
                   print("\(p)")
                }
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    }
    
    func testAuthRequest() {
        
        //https://www.coinbase.com/v2/oauth/authorize?scope=wallet:user:read,wallet:user:email,wallet:accounts:read&redirect_uri=thanger://com.bluoma.thanger/oauth/redir&client_secret=34cs&client_id=24ci&response_type=code&state=93C58288-82E7-4308-915B-3EC280195755
        let service = UserAccountService()
        
        if let urlRequest = service.createAuthorizationCodeRequest(withRedirectUrl: coinbaseOAuth2RedirectUri) {
            dlog("url: \(String(describing: urlRequest.url))")
            dlog("host: \(String(describing: urlRequest.url?.host))")

        }
        else {
            XCTFail("no urlRequest")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
