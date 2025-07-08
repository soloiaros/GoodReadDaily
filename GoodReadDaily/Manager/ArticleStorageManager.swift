//
//  ArticleStorageManager.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/8/25.
//

import Foundation

class ArticleStorage {
    private static let lastAssignmentDateKey = "lastArticleAssignmentDate"
    private static let todaysArticlesKey = "todaysArticles"
    
    static func storeTodaysArticles(_ articles: [Article]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(articles) {
            UserDefaults.standard.set(encoded, forKey: todaysArticlesKey)
            UserDefaults.standard.set(Date(), forKey: lastAssignmentDateKey)
        }
    }
    
    static func getTodaysArticles() -> [Article]? {
        // Check if we need new articles (crossed midnight)
        if shouldRefreshArticles() {
            return nil
        }
        
        // Return stored articles if available
        if let data = UserDefaults.standard.data(forKey: todaysArticlesKey) {
            let decoder = JSONDecoder()
            return try? decoder.decode([Article].self, from: data)
        }
        return nil
    }
    
    static func shouldRefreshArticles() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: lastAssignmentDateKey) as? Date else {
            return true
        }
        return !Calendar.current.isDateInToday(lastDate)
    }
}
