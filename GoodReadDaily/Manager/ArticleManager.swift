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
        let filteredArticles = allArticles.filter {
            article in
            genres.contains(article.genre)
        }
        
        if filteredArticles.count <= count {
            return filteredArticles.shuffled()
        }
        
        return Array(filteredArticles.shuffled().prefix(count))
    }
}
