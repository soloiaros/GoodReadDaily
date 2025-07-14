import Foundation
import SwiftData
import FirebaseAuth

class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setModelContainer(_ container: ModelContainer) {
        DispatchQueue.main.async {
            self.modelContainer = container
            self.modelContext = container.mainContext
            print("SwiftDataManager: ModelContainer set")
        }
    }
    
    @MainActor
    func getUserData() -> SDUserData? {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("SwiftDataManager: No authenticated user")
            return nil
        }
        guard let context = modelContext else {
            print("SwiftDataManager: ModelContext not initialized")
            return nil
        }
        
        let descriptor = FetchDescriptor<SDUserData>(predicate: #Predicate { $0.userId == userId })
        do {
            let users = try context.fetch(descriptor)
            if let userData = users.first {
                print("SwiftDataManager: Found userData for \(userId), hasSeenGenreScreen: \(userData.preferences.hasSeenGenreScreen)")
                return userData
            } else {
                print("SwiftDataManager: No userData for \(userId), creating new")
                let newUserData = SDUserData(userId: userId)
                context.insert(newUserData)
                try context.save()
                print("SwiftDataManager: Created and saved userData for \(userId), hasSeenGenreScreen: \(newUserData.preferences.hasSeenGenreScreen)")
                return newUserData
            }
        } catch {
            print("SwiftDataManager: Failed to fetch userData: \(error)")
            return nil
        }
    }
    
    @MainActor
    func save() {
        guard let context = modelContext else {
            print("SwiftDataManager: ModelContext not initialized")
            return
        }
        do {
            try context.save()
            print("SwiftDataManager: Context saved")
        } catch {
            print("SwiftDataManager: Failed to save context: \(error)")
        }
    }
    
    @MainActor
    func resetUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("SwiftDataManager: No authenticated user for reset")
            return
        }
        guard let context = modelContext else {
            print("SwiftDataManager: ModelContext not initialized")
            return
        }
        
        let descriptor = FetchDescriptor<SDUserData>(predicate: #Predicate { $0.userId == userId })
        do {
            let users = try context.fetch(descriptor)
            for user in users {
                context.delete(user)
            }
            let newUserData = SDUserData(userId: userId)
            context.insert(newUserData)
            try context.save()
            print("SwiftDataManager: Reset userData for \(userId), hasSeenGenreScreen: \(newUserData.preferences.hasSeenGenreScreen)")
        } catch {
            print("SwiftDataManager: Failed to reset userData: \(error)")
        }
    }
}
