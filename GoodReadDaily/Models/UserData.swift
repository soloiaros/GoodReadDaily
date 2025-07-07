//
//  UserData.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

struct UserData: Codable {
    var completedAtricleIDs: [String]
    var inProgressArticleIDs: [String]
    var savedWords: [DictionaryEntry]
    var preferences: UserPreferences
}
