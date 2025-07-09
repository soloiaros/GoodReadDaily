//
//  ArticlesManager.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import Foundation

class ArticleManager {
    static func loadArticles() -> [Article] {
        guard let url = Bundle.main.url(forResource: "Articles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let articles = try? JSONDecoder().decode([Article].self, from: data) else {
            print("Failed to load Articles.json file")
            return []
        }
        return articles
    }
    
    static func getRandomArticles(for genres: [String], count: Int) -> [Article] {
        let allArticles = loadArticles()
        
        if genres.isEmpty {
            return getArticlesWhenNoGenresSelected(count: count, from: allArticles)
        }
        
        let filteredArticles = allArticles.filter {
            article in
            genres.contains { $0.lowercased() == article.genre.lowercased() }
        }
        
        if filteredArticles.count <= count {
            return filteredArticles.shuffled()
        }
        
        return Array(filteredArticles.shuffled().prefix(count))
    }
    
    private static func getArticlesWhenNoGenresSelected(count: Int, from pool: [Article]) -> [Article] {
        guard !pool.isEmpty else { return [] }
        
        if pool.count <= count {
            return pool.shuffled()
        }
        
        return Array (pool.shuffled().prefix(count))
    }
}
