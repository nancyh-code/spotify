//
//  UserProfile.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    //let followers: Followers
    let id: String
    let images: [UserImage]?
    let product: String
}

struct UserImage: Codable {
    let url: String
}

/*struct Followers: Codable {
    let href: String?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case href
        case total
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        href = try values.decodeIfPresent(String.self, forKey: .href)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }
    
    init(href: String?, total: Int?) {
        self.href = href
        self.total = total
    }
}*/


