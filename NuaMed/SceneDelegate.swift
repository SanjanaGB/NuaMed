import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootVC: UIViewController

        if let user = Auth.auth().currentUser {
            // User is already logged in, go to Home
            rootVC = ImageCaptureViewController()
            print("User \(user.uid) is logged in, showing Home")
        } else {
            // Not logged in, show Login
            rootVC = LoginViewController()
        }

        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.isTranslucent = false

        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}
