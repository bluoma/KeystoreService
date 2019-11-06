//
//  CoinbaseUser.swift
//  thanger
//
//  Created by Bill on 11/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


/*
 {
   "data": {
     "id": "9da7a204-544e-5fd1-9a12-61176c5d4cd8",
     "name": "User One",
     "username": "user1",
     "profile_location": null,
     "profile_bio": null,
     "profile_url": "https://coinbase.com/user1",
     "avatar_url": "https://images.coinbase.com/avatar?h=vR%2FY8igBoPwuwGren5JMwvDNGpURAY%2F0nRIOgH%2FY2Qh%2BQ6nomR3qusA%2Bh6o2%0Af9rH&s=128",
     "resource": "user",
     "resource_path": "/v2/user"
   }
 }
 */

struct User: Encodable, CustomStringConvertible, Hashable {
    
    let id: String
    let name: String
    let username: String?
    let profileLocation: String?
    let profileBio: String?
    let profileUrl: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case username = "username"
        case profileLocation = "profile_location"
        case profileBio = "profile_bio"
        case profileUrl = "profile_url"
        case avatarUrl = "avatar_url"
    }
    
    var description: String {
        return "\(id):\(name):\(String(describing: username))\(String(describing: profileLocation)):\(String(describing: profileUrl)):\(String(describing: avatarUrl)))"
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension User: Decodable {
    
    enum DataKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DataKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        id = try dataContainer.decode(String.self, forKey: .id)
        name = try dataContainer.decode(String.self, forKey: .name)
        username = try dataContainer.decodeIfPresent(String.self, forKey: .username)
        profileLocation = try dataContainer.decodeIfPresent(String.self, forKey: .profileLocation)
        profileBio = try dataContainer.decodeIfPresent(String.self, forKey: .profileBio)
        profileUrl = try dataContainer.decodeIfPresent(String.self, forKey: .profileUrl)
        avatarUrl = try dataContainer.decodeIfPresent(String.self, forKey: .avatarUrl)
    }
}
