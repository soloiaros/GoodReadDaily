//
//  RegisterView.swift
//  GoodReadDaily
//
//  Created by Olga Eliseeva on 09.07.2025.
//


import UIKit
import FirebaseAuth

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
        
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
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
