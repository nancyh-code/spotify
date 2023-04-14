//
//  Artist.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import Foundation

struct Artist: Codable {
    let external_urls: [String: String]
    let id: String
    let name: String
    let type: String
}
