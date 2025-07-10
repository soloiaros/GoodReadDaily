//
//  UserData.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//


import Foundation
import SwiftData

@Model
class SDUserData {
    @Attribute(.unique) var userId: String // Links to Firebase user ID
    var completedArticleIDs: [String]
    var inProgressArticleIDs: [String]
    var todaysArticleIDs: [String]
    var lastRefreshDate: Date? // Added for user-specific refresh tracking
    var savedWords: [SDDictionaryEntry]
    var preferences: SDUserPreferences
    
    init(userId: String, completedArticleIDs: [String] = [], inProgressArticleIDs: [String] = [], todaysArticleIDs: [String] = [], lastRefreshDate: Date? = nil, savedWords: [SDDictionaryEntry] = [], preferences: SDUserPreferences = SDUserPreferences()) {
        self.userId = userId
        self.completedArticleIDs = completedArticleIDs
        self.inProgressArticleIDs = inProgressArticleIDs
        self.todaysArticleIDs = todaysArticleIDs
        self.lastRefreshDate = lastRefreshDate
        self.savedWords = savedWords
        self.preferences = preferences
    }
}

@Model
class SDUserPreferences {
    var genres: [String]
    var hasSeenGenreScreen: Bool
    
    init(genres: [String] = [], hasSeenGenreScreen: Bool = false) {
        self.genres = genres
        self.hasSeenGenreScreen = hasSeenGenreScreen
    }
}

@Model
class SDDictionaryEntry {
    var word: String
    var context: String?
    var dateAdded: Date
    
    init(word: String, context: String? = nil, dateAdded: Date = Date()) {
        self.word = word
        self.context = context
        self.dateAdded = dateAdded
    }
}
