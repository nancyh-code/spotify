//
//  PlaylistDetailsResponse.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 16-04-23.
//

import Foundation

struct PlaylistDeatailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTrackResponse
}

struct PlaylistTrackResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
