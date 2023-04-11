//
//  AuthResponse.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 11-04-23.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}



