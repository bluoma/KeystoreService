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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
