import UIKit
import FirebaseAuth

class LoadingViewController: UIViewController {
    
    private let loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // Changed to fill screen
        imageView.clipsToBounds = true // Ensure no overflow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        performInitialChecks()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Set the static image (replace "loadingImage" with your image name)
        loadingImageView.image = UIImage(named: "loadingImage")
        
        // Add activity indicator
        activityIndicator.startAnimating()
        
        view.addSubviews(activityIndicator, loadingImageView)
        
        // Full-screen image constraints
        NSLayoutConstraint.activate([
            loadingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Position activity indicator near bottom
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20) // 20 points from bottom
        ])
    }
    
    private func performInitialChecks() {
        // Simulate a 2-second delay to ensure Firebase and SwiftData are ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.routeToAppropriateScreen()
        }
    }
    
    private func routeToAppropriateScreen() {
        let rootVC: UIViewController
        
        if let user = Auth.auth().currentUser {
            print("LoadingViewController: User logged in, UID: \(user.uid)")
            if let userData = SwiftDataManager.shared.getUserData() {
                print("LoadingViewController: UserData found, hasSeenGenreScreen: \(userData.preferences.hasSeenGenreScreen)")
                rootVC = userData.preferences.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
            } else {
                print("LoadingViewController: Failed to fetch or create UserData for UID: \(user.uid)")
                rootVC = GenreSelectionViewController() // Fallback
            }
        } else {
            print("LoadingViewController: No user logged in")
            rootVC = LoginViewController()
        }
        
        // Transition to the new root view controller
        let navController = UINavigationController(rootViewController: rootVC)
        navController.modalPresentationStyle = .fullScreen
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = navController
            window.makeKeyAndVisible()
            
            // Fade transition
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .fade
            window.layer.add(transition, forKey: kCATransition)
        }
        
        print("LoadingViewController: Root VC set to: \(String(describing: type(of: rootVC)))")
    }
}
