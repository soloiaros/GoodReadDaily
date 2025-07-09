//
//  DictionaryAPIService.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/9/25.
//

import Foundation

struct FreeDictionaryResponse: Codable {
    let word: String
    let phonetic: String?
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let license: License
    let sourceUrls: [String]
}

struct Phonetic: Codable {
    let text: String?
    let audio: String?
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms: [String]
    let antonyms: [String]
}

struct Definition: Codable {
    let definition: String
    let example: String?
    let synonyms: [String]
    let antonyms: [String]
}

struct License: Codable {
    let name: String
    let url: String
}

class DictionaryAPIService {
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    func fetchWordDetails(word: String, completion: @escaping (Result<[FreeDictionaryResponse], Error>) -> Void) {
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: baseURL + encodedWord) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    completion(.failure(URLError(.resourceUnavailable)))
                    return
                }
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            print(String(data: data, encoding: .utf8) ?? "Invalid response data")
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode([FreeDictionaryResponse].self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
