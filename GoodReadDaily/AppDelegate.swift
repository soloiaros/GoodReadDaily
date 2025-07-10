//
//  AppDelegate.swift
//  GoodReadDaily
//  Created by Yaroslav Solovev on 7/4/25.
//

import UIKit
import SwiftData
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize SwiftData container
        do {
            let container = try ModelContainer(for: SDUserData.self, SDDictionaryEntry.self, SDUserPreferences.self)
            SwiftDataManager.shared.setModelContainer(container)
        } catch {
            print("Failed to initialize SwiftData container: \(error)")
        }
        return true
    }
}
