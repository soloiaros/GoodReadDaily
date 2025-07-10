//
//  SceneDelegate.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/4/25.
//


import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootVC: UIViewController
        if Auth.auth().currentUser != nil {
            if let userData = SwiftDataManager.shared.getUserData() {
                rootVC = userData.preferences.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
            } else {
                rootVC = GenreSelectionViewController() // Fallback if user data fetch fails
            }
        } else {
            rootVC = LoginViewController()
        }
        
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
