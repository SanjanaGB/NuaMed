import UIKit
import FirebaseAuth

class LogoutViewController: UIViewController {
    func doLogout() {
        do {
            try Auth.auth().signOut()
            
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate,
            let window = sceneDelegate.window {
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }else{
                self.navigationController?.setViewControllers([loginVC], animated: true)
            }
        } catch {
            let alert = UIAlertController(
                        title: "Error",
                        message: "Error signing out: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
}
