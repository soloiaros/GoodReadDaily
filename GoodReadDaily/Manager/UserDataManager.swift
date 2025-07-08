//
//  UserDataManager.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserDataManager {
    static let shared = UserDataManager()
    
    private let userDataKey = "userData"
    
    var userData: UserData
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: userDataKey),
           let decoded = try? JSONDecoder().decode(UserData.self, from: data) {
            self.userData = decoded
        } else {
            self.userData = UserData(
                completedArticleIDs: [],
                inProgressArticleIDs: [],
                savedWords: [],
                preferences: UserPreferences(genres: [], hasSeenGenreScreen: false)
            )
        }
    }
        
    func save() {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: userDataKey)
        }
    }
    
    func reset() {
        self.userData = UserData(
            completedArticleIDs: [],
            inProgressArticleIDs: [],
            savedWords: [],
            preferences: UserPreferences(genres: [], hasSeenGenreScreen: false)
        )

        UserDefaults.standard.removeObject(forKey: userDataKey)
        UserDefaults.standard.synchronize()
    }
}

