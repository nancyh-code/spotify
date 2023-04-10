//
//  AuthManager.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 10-04-23.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "8cf8c24f22da4f81ad868cd1db627c63"
        static let clientSecret = "9d31fe53fa2b4353a2ba974a525da5ea"
    }
    
    private init() {
        
    }
    
    var isSignedIn: Bool {
        return false
    }
    
    private var accesToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
}
