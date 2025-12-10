import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        //Create a local non-optional window
        let window = UIWindow(windowScene: windowScene)

        if let user = Auth.auth().currentUser {
            //User is logged in: show tab bar (Search as middle tab)
            print("User \(user.uid) is logged in, showing Search")
            window.rootViewController = BottomTabBarController()
        } else {
            //Not logged in: show login inside nav
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.navigationBar.isTranslucent = false
            window.rootViewController = nav
        }

        //Store it on the property so the system keeps a strong reference
        self.window = window
        window.makeKeyAndVisible()
    }
}

