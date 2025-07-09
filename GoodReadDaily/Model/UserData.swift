//
//  UserData.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

struct UserData: Codable {
    var completedArticleIDs: [String]
    var inProgressArticleIDs: [String]
    var savedWords: [DictionaryEntry]
    var todaysArticles: [Article] = []
    var preferences: UserPreferences
    
    init(
        completedArticleIDs: [String] = [],
        inProgressArticleIDs: [String] = [],
        savedWords: [DictionaryEntry] = [],
        todaysArticles: [Article] = [],
        preferences: UserPreferences = UserPreferences()
    ) {
        self.completedArticleIDs = completedArticleIDs
        self.inProgressArticleIDs = inProgressArticleIDs
        self.savedWords = savedWords
        self.todaysArticles = todaysArticles
        self.preferences = preferences
    }
}
