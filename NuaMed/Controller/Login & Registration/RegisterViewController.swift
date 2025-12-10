import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    private let registerView = RegisterView()

    override func loadView() {
        view = registerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        registerView.delegate = self
        
        setupNavigationBar(title: "Register") { [weak self] in
            guard let self = self else { return }
            let login = LoginViewController()
            self.navigationController?.setViewControllers([login], animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let message = """
        1. All fields are mandatory.
        2. Username should be unique and contain only letters and numbers.
        3. Email should be unique. If already registered, login. 
        4. If forgotten password, use the 'Forgot Password' link on login page.
        5. Password should be at least 6 characters long.
        """
        
        let alert = UIAlertController(title: "Registration Guidelines", message: message, preferredStyle: .alert)
        
        // OK button, stays on the register page
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Go Back button, navigates to login page
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel) { _ in
            let loginVC = LoginViewController()
            self.navigationController?.setViewControllers([loginVC], animated: true)
        })
        
        present(alert, animated: true)
    }

}

extension RegisterViewController: RegisterViewDelegate {
    func didTapRegister(username: String, email: String, password: String) {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please fill all fields")
            return
        }

        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        
        guard isValidUsername(username) else {
            showAlert(
                title: "Invalid Username",
                message: "Username can only contain letters and numbers, no spaces or special characters."
            )
            return
        }


        FirebaseService.shared.isUsernameTaken(username) { usernameTaken in
            if usernameTaken {
                DispatchQueue.main.async {
                    self.showAlert(title: "Username Taken", message: "Username already exists. Please choose another or login.")
                }
                return
            }

            Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }

                    if let methods = methods, !methods.isEmpty {
                        self.showAlert(title: "Email Exists", message: "Email is already registered. Please login instead.")
                        return
                    }

                    FirebaseService.shared.register(username: username, email: email, password: password) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(let err):
                                self.showAlert(title: "Register Error", message: err.localizedDescription)
                            case .success:
                                self.showAlert(title: "Registered", message: "Registration successful. Please login.", onOk: {
                                    self.navigationController?.popViewController(animated: true)
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    func didTapBackToLogin() {
        navigationController?.popViewController(animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        let pattern = "^[A-Za-z0-9]+$"
        return username.range(of: pattern, options: .regularExpression) != nil
    }

}
