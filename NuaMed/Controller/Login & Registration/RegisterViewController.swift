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
}
