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
}
