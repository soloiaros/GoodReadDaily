import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    private let welcomeLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let passwordToggleButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        setupUI()
    }
    
    private func configureTextFields() {
        // Email Field
        emailField.autocapitalizationType = .none
        emailField.placeholder = "Enter your email"
        emailField.keyboardType = .emailAddress
        emailField.borderStyle = .none
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.systemGray5.cgColor
        emailField.backgroundColor = .systemBackground
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailField.leftViewMode = .always
        emailField.font = .systemFont(ofSize: 16)
        emailField.layer.masksToBounds = true
        emailField.layer.shadowColor = UIColor.black.cgColor
        emailField.layer.shadowOpacity = 0.1
        emailField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailField.layer.shadowRadius = 4
        
        // Password Field
        passwordField.autocapitalizationType = .none
        passwordField.placeholder = "Enter your password"
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .none
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.systemGray5.cgColor
        passwordField.backgroundColor = .systemBackground
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        passwordField.leftViewMode = .always
        
        // Password Toggle Button
        passwordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        passwordToggleButton.tintColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
        passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Container for toggle button with left padding
        let toggleContainer = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 40))
        passwordToggleButton.frame = CGRect(x: 8, y: 0, width: 40, height: 40)
        toggleContainer.addSubview(passwordToggleButton)
        passwordField.rightView = toggleContainer
        passwordField.rightViewMode = .always
        
        passwordField.font = .systemFont(ofSize: 16)
        passwordField.layer.masksToBounds = true
        passwordField.layer.shadowColor = UIColor.black.cgColor
        passwordField.layer.shadowOpacity = 0.1
        passwordField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordField.layer.shadowRadius = 4
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        
        // Welcome Label
        welcomeLabel.text = "Welcome Back!"
        welcomeLabel.font = .systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textColor = .label
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Login Button
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
        loginButton.layer.cornerRadius = 12
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        loginButton.layer.masksToBounds = true
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.shadowRadius = 4
        
        // Register Button
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.setTitleColor(UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5), for: .normal)
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 12
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5).cgColor
        registerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        // Stack View
        let stackView = UIStackView(arrangedSubviews: [welcomeLabel, emailField, passwordField, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func signInTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.routeAfterLogin()
                }
            }
        }
    }
    
    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        registerVC.onRegistrationSuccess = { [weak self] email, password in
            self?.emailField.text = email
            self?.passwordField.text = password
            self?.signInTapped()
        }
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func routeAfterLogin() {
        let rootVC: UIViewController
        if let userData = SwiftDataManager.shared.getUserData() {
            rootVC = userData.preferences.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
        } else {
            rootVC = GenreSelectionViewController()
        }
        let navController = UINavigationController(rootViewController: rootVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showError(_ error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
