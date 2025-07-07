//
//  LoginViewController.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import UIKit

class LoginViewController: UIViewController {
    let emailField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton(type: .system)
    let registerButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.autocapitalizationType = .none
        passwordField.autocapitalizationType = .none
        
        view.backgroundColor = .systemBackground
        
        title = "Login"
        setupUI()
    }
    
    func setupUI() {
        emailField.placeholder = "Email"
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        
        loginButton.setTitle("Sign In", for: .normal)
        registerButton.setTitle("Don't have an account?", for: .normal)
        
        loginButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField, loginButton, registerButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    @objc func signInTapped() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        AuthManager.shared.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.routeAfterLogin()
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }
    
    @objc func registerTapped() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        AuthManager.shared.register(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.routeAfterLogin()
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }

    func routeAfterLogin() {
        let prefs = UserDataManager.shared.userData.preferences
        if prefs.hasSeenGenreScreen {
            let mainVC = MainViewController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true)
        } else {
            let genreVC = GenreSelectionViewController()
            genreVC.modalPresentationStyle = .fullScreen
            self.present(genreVC, animated: true)
        }
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
