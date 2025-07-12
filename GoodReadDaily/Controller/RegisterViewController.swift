import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    var onRegistrationSuccess: ((String, String) -> Void)?
    
    private let welcomeLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let passwordToggleButton = UIButton(type: .custom)
    private let confirmPasswordToggleButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        
        configureWelcomeLabel()
        configureTextFields()
        configureRegisterButton()
        setupStackView()
    }
    
    private func configureWelcomeLabel() {
        welcomeLabel.text = "Join Us!"
        welcomeLabel.font = .systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textColor = .label
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTextFields() {
        // Email Field
        emailField.placeholder = "Enter your email"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
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
        passwordField.placeholder = "Create a password"
        passwordField.isSecureTextEntry = true
        passwordField.autocapitalizationType = .none
        passwordField.textContentType = .newPassword
        passwordField.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 6; required: lower; required: upper; required: digit;")
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
        
        // Container for password toggle button with left padding
        let passwordToggleContainer = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 40))
        passwordToggleButton.frame = CGRect(x: 8, y: 0, width: 40, height: 40)
        passwordToggleContainer.addSubview(passwordToggleButton)
        passwordField.rightView = passwordToggleContainer
        passwordField.rightViewMode = .always
        
        passwordField.font = .systemFont(ofSize: 16)
        passwordField.layer.masksToBounds = true
        passwordField.layer.shadowColor = UIColor.black.cgColor
        passwordField.layer.shadowOpacity = 0.1
        passwordField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordField.layer.shadowRadius = 4
        
        // Confirm Password Field
        confirmPasswordField.placeholder = "Confirm your password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.autocapitalizationType = .none
        confirmPasswordField.textContentType = .newPassword
        confirmPasswordField.borderStyle = .none
        confirmPasswordField.layer.cornerRadius = 12
        confirmPasswordField.layer.borderWidth = 1
        confirmPasswordField.layer.borderColor = UIColor.systemGray5.cgColor
        confirmPasswordField.backgroundColor = .systemBackground
        confirmPasswordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        confirmPasswordField.leftViewMode = .always
        
        // Confirm Password Toggle Button
        confirmPasswordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        confirmPasswordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        confirmPasswordToggleButton.tintColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
        confirmPasswordToggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        
        // Container for confirm password toggle button with left padding
        let confirmToggleContainer = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 40))
        confirmPasswordToggleButton.frame = CGRect(x: 8, y: 0, width: 40, height: 40)
        confirmToggleContainer.addSubview(confirmPasswordToggleButton)
        confirmPasswordField.rightView = confirmToggleContainer
        confirmPasswordField.rightViewMode = .always
        
        confirmPasswordField.font = .systemFont(ofSize: 16)
        confirmPasswordField.layer.masksToBounds = true
        confirmPasswordField.layer.shadowColor = UIColor.black.cgColor
        confirmPasswordField.layer.shadowOpacity = 0.1
        confirmPasswordField.layer.shadowOffset = CGSize(width: 0, height: 2)
        confirmPasswordField.layer.shadowRadius = 4
    }
    
    private func configureRegisterButton() {
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
        registerButton.layer.cornerRadius = 12
        registerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.layer.masksToBounds = true
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        registerButton.layer.shadowRadius = 4
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [
            welcomeLabel, emailField, passwordField, confirmPasswordField, registerButton
        ])
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
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 50),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
    }
    
    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordField.isSecureTextEntry.toggle()
        confirmPasswordToggleButton.isSelected.toggle()
    }
    
    @objc private func registerTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords don't match")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self?.onRegistrationSuccess?(email, password)
                    self?.rootAfterRegister()
                }
            }
        }
    }
    private func rootAfterRegister() {
        let rootVC: UIViewController
        if let userData = SwiftDataManager.shared.getUserData() {
            print("LoginViewController: UserData found, hasSeenGenreScreen: \(userData.preferences.hasSeenGenreScreen)")
            rootVC = userData.preferences.hasSeenGenreScreen ? MainViewController() : GenreSelectionViewController()
        } else {
            print("LoginViewController: No userData found, routing to GenreSelectionViewController")
            rootVC = GenreSelectionViewController()
        }
        navigationController?.setViewControllers([rootVC], animated: true)
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
