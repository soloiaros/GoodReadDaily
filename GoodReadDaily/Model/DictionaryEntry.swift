//
//  DictionaryEntry.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import Foundation

struct DictionaryEntry: Codable, Identifiable, Equatable {
    let id: String
    let word: String
    let context: String?
    let dateAdded: Date
    
    init(word: String, context: String? = nil, dateAdded: Date = Date()) {
        self.id = UUID().uuidString
        self.word = word
        self.context = context
        self.dateAdded = dateAdded
    }
}
