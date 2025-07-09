//
//  RegisterView.swift
//  GoodReadDaily
//
//  Created by Olga Eliseeva on 09.07.2025.
//
import UIKit

class LoginViewController: UIViewController {
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        setupUI()
    }
    
    private func configureTextFields() {
        emailField.autocapitalizationType = .none
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        
        passwordField.autocapitalizationType = .none
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Login"
        
        // Configure buttons
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        // Create stack view
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    @objc private func signInTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.routeAfterLogin()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        registerVC.onRegistrationSuccess = { [weak self] email, password in
            self?.emailField.text = email
            self?.passwordField.text = password
            self?.signInTapped() // Automatically sign in after registration
        }
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func routeAfterLogin() {
        UserDataManager.shared.reset()

        let prefs = UserDataManager.shared.userData.preferences
        let rootVC = prefs.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
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
