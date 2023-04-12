//
//  SettingsModels.swift
//  Spotify
//
//  Created by Nancy Hernandez Yanez on 11-04-23.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
