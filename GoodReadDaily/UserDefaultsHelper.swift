//
//  UserDefaultsHelper.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/8/25.
//

import Foundation

struct UserDefaultsHelper {
    static var userData: UserData? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "userData") else { return nil }
            return try? JSONDecoder().decode(UserData.self, from: data)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "userData")
            }
        }
    }
    
    static func addDictionaryEntry(_ entry: DictionaryEntry) {
        var currentData = userData ?? UserData(
            completedArticleIDs: [],
            inProgressArticleIDs: [],
            savedWords: [],
            todaysArticles: [],
            preferences: UserPreferences()
        )
        
        if !currentData.savedWords.contains(where: { $0.word.lowercased() == entry.word.lowercased() }) {
            currentData.savedWords.append(entry)
            userData = currentData
        }
    }
}
