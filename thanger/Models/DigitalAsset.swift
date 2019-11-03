//
//  DigitalAsset.swift
//  thanger
//
//  Created by Bill on 11/2/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

/*
 https://api.coinbase.com/v2/assets/info?&locale=en&filter=listed
 {
     "id": "5b71fc48-3dd3-540c-809b-f8c94d0e68b5",
     "symbol": "BTC",
     "name": "Bitcoin",
     "slug": "bitcoin",
     "uri_scheme": "bitcoin",
     "color": "#F7931A",
     "asset_type": "currency",
     "image_url": "https://dynamic-assets.coinbase.com/e785e0181f1a23a30d9476038d9be91e9f6c63959b538eabbc51a1abc8898940383291eede695c3b8dfaa1829a9b57f5a2d0a16b0523580346c6b8fab67af14b/asset_icons/b57ac673f06a4b0338a596817eb0a50ce16e2059f327dc117744449a47915cb2.png",
     "listed": true,
     "description": "The world’s first cryptocurrency, Bitcoin is stored and exchanged securely on the internet through a digital ledger known as a blockchain. Bitcoins are divisible into smaller units known as satoshis — each satoshi is worth 0.00000001 bitcoin.",
     "asset_type_description": "Cryptocurrency",
     "website": "https://bitcoin.org",
     "white_paper": "https://bitcoin.org/bitcoin.pdf",
     "exponent": 8,
     "unit_price_scale": 2,
     "transaction_unit_price_scale": 2,
     "contract_address": null,
     "address_regex": "^([13][a-km-zA-HJ-NP-Z1-9]{25,34})|^(bc1([qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}))$",
     "price_alerts_enabled": true,
     "recently_listed": false,
     "resource_urls": [
         {
             "type": "website",
             "icon_url": "https://www.coinbase.com/assets/resource_types/globe-58759be91aea7a349aff0799b2cba4e93028c83ebb77ca73fd18aba31050fc33.png",
             "title": "Official website",
             "link": "https://bitcoin.org"
         },
         {
             "type": "white_paper",
             "icon_url": "https://www.coinbase.com/assets/resource_types/white_paper-1129060acdfdb91628bf872c279435c9ce93245a40f0227d98f0aa0a93548cb4.png",
             "title": "Whitepaper",
             "link": "https://bitcoin.org/bitcoin.pdf"
         }
     ],
     "features_info": null,
     "images": null,
     "links": null,
     "related_assets": [
         "d85dce9b-5b73-5c3c-8978-522ce1d1c1b4",
         "e17a44c8-6ea1-564f-a02c-2a9ca1d8eec4",
         "45f99e13-b522-57d7-8058-c57bf92fe7a3",
         "c9c24c6e-c045-5fde-98a2-00ea7f520437",
         "8d556883-6c26-5a88-9d8f-fa41fe8ed76e",
         "3512a0ee-b6a5-59ab-b739-5707dc0f7255",
         "13b83335-5ede-595b-821e-5bcdfa80560f",
         "ea3107c6-416b-5b02-b99f-ded31a0cbdfe",
         "b9c43d61-e77d-5e02-9a0d-800b50eb9d5f",
         "69e559ec-547a-520a-aeb3-01cac23f1826",
         "c16df856-0345-5358-8a70-2a78c804e61f",
         "2b92315d-eab7-5bef-84fa-089a131333f5",
         "b8950bef-d61b-53cd-bb66-db436f0f81bc",
         "1d3c2625-a8d9-5458-84d0-437d75540421",
         "a2a8f5ae-83a6-542e-9064-7d335ae8a58d",
         "b8b44189-a54b-526f-b68d-1dbb27b462c3",
         "01e9e33b-d099-56fb-aa3b-76c19d0b250e"
     ],
     "supported": true
 }
 
 */


struct DigitalAsset: Codable, CustomStringConvertible {
    
    let id: String
    let symbol: String
    let name: String
    let slug: String
    let color: String
    let assetType: String
    let exponent: Int
    let unitPriceScale: Int
    let transactionUnitPriceScale: Int
    let imageUrl: String
    let listed: Bool
    let supported: Bool
    let desc: String
    let assetTypeDesc: String
    let website: String
    let whitePaper: String?
   
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, slug, color, exponent, listed, website, supported
        case assetType = "asset_type"
        case unitPriceScale = "unit_price_scale"
        case transactionUnitPriceScale = "transaction_unit_price_scale"
        case imageUrl = "image_url"
        case desc = "description"
        case assetTypeDesc = "asset_type_description"
        case whitePaper = "white_paper"

    }
    
    var description: String {
        return "\(id):\(symbol):\(name)"
    }
}

struct DigitalAssetResult: Codable {
    
    let assets: [DigitalAsset]
    
    enum CodingKeys: String, CodingKey {
        case assets = "data"
    }
}
