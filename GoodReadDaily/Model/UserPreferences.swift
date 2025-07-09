//
//  UserPreferences.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

struct UserPreferences: Codable {
    var genres: [String]
    var hasSeenGenreScreen: Bool
    
    init(genres: [String] = [], hasSeenGenreScreen: Bool = false) {
        self.genres = genres
        self.hasSeenGenreScreen = hasSeenGenreScreen
    }
}
