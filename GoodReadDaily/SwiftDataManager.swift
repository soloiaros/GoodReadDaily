
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
        }
    }
    
    // Fetch or create user data for the current Firebase user
    @MainActor
    func getUserData() -> SDUserData? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<SDUserData>(predicate: #Predicate { $0.userId == userId })
        do {
            let users = try context.fetch(descriptor)
            if let userData = users.first {
                return userData
            } else {
                // Create new user data if none exists
                let newUserData = SDUserData(userId: userId)
                context.insert(newUserData)
                try context.save()
                return newUserData
            }
        } catch {
            print("Failed to fetch user data: \(error)")
            return nil
        }
    }
    
    // Save changes to the context
    @MainActor
    func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Reset user data (for testing or initialization, not used on logout)
    @MainActor
    func resetUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<SDUserData>(predicate: #Predicate { $0.userId == userId })
        do {
            let users = try context.fetch(descriptor)
            for user in users {
                context.delete(user)
            }
            let newUserData = SDUserData(userId: userId)
            context.insert(newUserData)
            try context.save()
        } catch {
            print("Failed to reset user data: \(error)")
        }
    }
}
