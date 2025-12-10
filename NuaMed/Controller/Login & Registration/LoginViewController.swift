//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class LoginViewController: UIViewController {
//    private let loginView = LoginView()
//
//    override func loadView() {
//        view = loginView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "MyAppName"
//        loginView.delegate = self
//        
//        setupNavigationBar(title: "Login") {
//            // Do nothing on back, or provide a custom action if needed
//        }
//
//        navigationItem.hidesBackButton = true
//        navigationItem.leftBarButtonItem = nil
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//
//    }
//}
//
//extension LoginViewController: LoginViewDelegate {
//    func didTapLogin(username: String, password: String) {
//        guard !username.isEmpty && !password.isEmpty else {
//            showAlert(title: "Missing", message: "Enter username/email and password")
//            return
//        }
//
//        func signInWithEmail(_ email: String) {
//            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        self.showAlert(title: "Error", message: "Invalid username/email or password")
//                        return
//                    }
//                    
//                    
//
//                    guard let uid = authResult?.user.uid else {
//                        self.showAlert(title: "Error", message: "Invalid username/email or password")
//                        return
//                    }
//
//                    FirebaseService.shared.fetchUserProfile(uid: uid) { profileRes in
//                        DispatchQueue.main.async {
//                            switch profileRes {
//                            case .failure:
//                                self.showAlert(title: "Error", message: "Couldn't fetch profile")
//                            case .success(let profile):
//                                if profile.profileSetup {
//                                    self.goToSearchPage()
//
//                                } else {
//                                    let alert = UIAlertController(title: "Profile", message: "Set up your profile now?", preferredStyle: .alert)
//                                    alert.addAction(UIAlertAction(title: "Set up", style: .default) { _ in
//                                        let vc = ProfileSetupViewController()
//                                        self.navigationController?.pushViewController(vc, animated: true)
//                                    })
//                                    alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { _ in
//                                        self.goToSearchPage()
//                                    })
//                                    self.present(alert, animated: true)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        if username.contains("@") {
//            signInWithEmail(username)
//        } else {
//            FirebaseService.shared.fetchUserProfileByUsername(username: username) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .failure:
//                        self.showAlert(title: "Error", message: "Login failed")
//                    case .success(let profile):
//                        signInWithEmail(profile.email)
//                        
//                    }
//                }
//            }
//        }
//    }
//
//
//    func didTapRegister() {
//        let vc = RegisterViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func didTapForgotPassword(emailOrUsername: String?) {
//        let alert = UIAlertController(
//            title: "Reset Password",
//            message: "Enter your registered email",
//            preferredStyle: .alert
//        )
//        
//        alert.addTextField { textField in
//            textField.placeholder = "Email"
//        }
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
//            guard let email = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//                  !email.isEmpty else {
//                self.showAlert(title: "Missing Email", message: "Please enter a valid email.")
//                return
//            }
//            
//            // Send the password reset email
//            FirebaseService.shared.sendPasswordReset(toEmail: email) { err in
//                DispatchQueue.main.async {
//                    if let err = err {
//                        self.showAlert(title: "Error", message: err.localizedDescription)
//                    } else {
//                        self.showAlert(
//                            title: "Email Sent",
//                            message: "If this email is registered, you will receive a password reset link."
//                        )
//                    }
//                }
//            }
//        }))
//        
//        self.present(alert, animated: true)
//    }
//    private func goToSearchPage() {
//        guard
//            let windowScene = view.window?.windowScene,
//            let sceneDelegate = windowScene.delegate as? SceneDelegate,
//            let window = sceneDelegate.window
//        else { return }
//
//        let tabBar = BottomTabBarController()
//        tabBar.selectedIndex = 1   // middle tab = Search
//
//        //Animated transition
//        UIView.transition(with: window, duration: 0.3, options: [.transitionFlipFromRight], animations: {
//            window.rootViewController = tabBar
//        }, completion: nil)
//    }
//}


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
            // custom back button action (if needed)
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
                    if let _ = error {
                        self.showAlert(title: "Error", message: "Invalid username/email or password")
                        return
                    }

                    guard let uid = authResult?.user.uid else {
                        self.showAlert(title: "Error", message: "Invalid username/email or password")
                        return
                    }

                    // Fetch user profile from Firestore
                    FirebaseService.shared.fetchUserProfile(uid: uid) { profileRes in
                        DispatchQueue.main.async {
                            switch profileRes {
                                
                            case .failure:
                                self.showAlert(title: "Error", message: "Couldn't fetch profile")

                            case .success(let profile):

                                // 1️⃣ Store entire user object in memory
                                UserProfileManager.shared.setCurrentUser(profile)

                                // 2️⃣ Load allergies, medications, medicalConditions
                                UserProfileManager.shared.loadUserProfile {
                                    print("User health profile loaded")

                                    // 3️⃣ Continue login flow based on profileSetup
                                    if profile.profileSetup {
                                        self.goToSearchPage()

                                    } else {
                                        let alert = UIAlertController(
                                            title: "Profile",
                                            message: "Set up your profile now?",
                                            preferredStyle: .alert
                                        )

                                        alert.addAction(UIAlertAction(title: "Set up", style: .default) { _ in
                                            let vc = ProfileSetupViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        })

                                        alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { _ in
                                            self.goToSearchPage()
                                        })

                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // If username contains @ treat as email
        if username.contains("@") {
            signInWithEmail(username)

        } else {
            // login by username
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
        let alert = UIAlertController(
            title: "Reset Password",
            message: "Enter your registered email",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Email"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
            guard let email = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !email.isEmpty else {
                self.showAlert(title: "Missing Email", message: "Please enter a valid email.")
                return
            }

            FirebaseService.shared.sendPasswordReset(toEmail: email) { err in
                DispatchQueue.main.async {
                    if let err = err {
                        self.showAlert(title: "Error", message: err.localizedDescription)
                    } else {
                        self.showAlert(
                            title: "Email Sent",
                            message: "If this email is registered, you will receive a password reset link."
                        )
                    }
                }
            }
        }))

        self.present(alert, animated: true)
    }
    
    private func goToSearchPage() {
        guard
            let windowScene = view.window?.windowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else { return }

        let tabBar = BottomTabBarController()
        tabBar.selectedIndex = 1   // middle tab = Search

        UIView.transition(with: window, duration: 0.3, options: [.transitionFlipFromRight], animations: {
            window.rootViewController = tabBar
        }, completion: nil)
    }
}



