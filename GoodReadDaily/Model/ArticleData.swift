//
//  Article.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import Foundation

struct Article: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let author: String
    let genre: String
    let content: String
}
