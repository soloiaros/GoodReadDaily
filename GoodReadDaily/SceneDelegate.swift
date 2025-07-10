import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    @MainActor
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootVC: UIViewController
        if let user = Auth.auth().currentUser {
            print("SceneDelegate: User logged in, UID: \(user.uid)")
            if let userData = SwiftDataManager.shared.getUserData() {
                print("SceneDelegate: UserData found, hasSeenGenreScreen: \(userData.preferences.hasSeenGenreScreen)")
                rootVC = userData.preferences.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
            } else {
                print("SceneDelegate: Failed to fetch or create UserData for UID: \(user.uid)")
                rootVC = GenreSelectionViewController() // Fallback for unexpected failure
            }
        } else {
            print("SceneDelegate: No user logged in")
            rootVC = LoginViewController()
        }
        
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()
        print("SceneDelegate: Root VC set to: \(String(describing: type(of: rootVC)))")
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
