//
//  NewReleasesResponse.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 12-04-23.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String
    let artists: [Artist]    
}


