//LoginVC
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    private let welcomeLabel : UILabel = {
        let label = UILabel()
        label.text = "Welcome Back!"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.placeholder = "Enter your email"
        field.keyboardType = .emailAddress
        field.borderStyle = .none
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.backgroundColor = .systemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.font = .systemFont(ofSize: 16)
        field.layer.masksToBounds = true
        field.layer.shadowColor = UIColor.black.cgColor
        field.layer.shadowOpacity = 0.1
        field.layer.shadowOffset = CGSize(width: 0, height: 2)
        field.layer.shadowRadius = 4
        return field
    }()
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.placeholder = "Enter your password"
        field.isSecureTextEntry = true
        field.borderStyle = .none
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.backgroundColor = .systemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    private let registerButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5).cgColor
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()
    
    private let passwordToggleButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        setupUI()
    }
    
    private func configureTextFields() {
        // Email Field
       
        
        // Password Field
       
        
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

    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        
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
        let mainVC = MainViewController()
        navigationController?.setViewControllers([mainVC], animated: true)
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

