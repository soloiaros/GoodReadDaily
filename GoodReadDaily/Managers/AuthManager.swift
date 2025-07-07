//
//  AuthManager.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    func currentUser() -> User? {
        return Auth.auth().currentUser
    }
}
