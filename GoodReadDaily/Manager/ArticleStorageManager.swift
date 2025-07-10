//
//  ArticleStorageManager.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/8/25.
//

import Foundation
import SwiftData
import FirebaseAuth

class ArticleStorage {
    @MainActor
    static func shouldRefreshArticles() -> Bool {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            return true // Refresh if no user data (e.g., not logged in)
        }
        guard let lastRefreshDate = userData.lastRefreshDate else {
            return true // Refresh if no previous refresh date
        }
        return !Calendar.current.isDateInToday(lastRefreshDate)
    }
    
    @MainActor
    static func updateRefreshTimestamp() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            return
        }
        userData.lastRefreshDate = Date()
        SwiftDataManager.shared.save()
    }
}
