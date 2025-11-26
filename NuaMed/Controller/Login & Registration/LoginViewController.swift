import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    private let loginView = LoginView()

    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MyAppName"
        loginView.delegate = self
        
        setupNavigationBar(title: "Login") {
            // Do nothing on back, or provide a custom action if needed
        }

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
}

extension LoginViewController: LoginViewDelegate {
    func didTapLogin(username: String, password: String) {
        guard !username.isEmpty && !password.isEmpty else {
            showAlert(title: "Missing", message: "Enter username/email and password")
            return
        }

        func signInWithEmail(_ email: String) {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showAlert(title: "Error", message: "Invalid email or password")
                        return
                    }

                    guard let uid = authResult?.user.uid else {
                        self.showAlert(title: "Error", message: "Invalid email or password")
                        return
                    }

                    FirebaseService.shared.fetchUserProfile(uid: uid) { profileRes in
                        DispatchQueue.main.async {
                            switch profileRes {
                            case .failure:
                                self.showAlert(title: "Error", message: "Couldn't fetch profile")
                            case .success(let profile):
                                if profile.profileSetup {
                                    let home = SearchViewController()
                                    self.navigationController?.setViewControllers([home], animated: true)
                                } else {
                                    let alert = UIAlertController(title: "Profile", message: "Set up your profile now?", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Set up", style: .default) { _ in
                                        let vc = ProfileSetupViewController()
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    })
                                    alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { _ in
                                        let home = SearchViewController()
                                        self.navigationController?.setViewControllers([home], animated: true)
                                    })
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }

        if username.contains("@") {
            signInWithEmail(username)
        } else {
            FirebaseService.shared.fetchUserProfileByUsername(username: username) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.showAlert(title: "Error", message: "Login failed")
                    case .success(let profile):
                        signInWithEmail(profile.email)
                    }
                }
            }
        }
    }


    func didTapRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapForgotPassword(emailOrUsername: String?) {
        guard let entry = emailOrUsername, !entry.isEmpty else {
            showAlert(title: "Enter email", message: "Enter your email in the field and tap Forgot Password.")
            return
        }

        if entry.contains("@") {
            FirebaseService.shared.sendPasswordReset(toEmail: entry) { err in
                DispatchQueue.main.async {
                    if let err = err {
                        self.showAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        self.showAlert(title: "Sent", message: "If email is already registered, password reset email will be sent.")
                    }
                }
            }
        }
            
    }
}
