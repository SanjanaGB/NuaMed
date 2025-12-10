import UIKit
import FirebaseAuth

protocol ProfileDrawerDelegate: AnyObject {
    func profileDrawerDidTapEditProfile(_ drawer:       ProfileNavigationDrawerViewController)
    func profileDrawerDidTapProductHistory(_ drawer:    ProfileNavigationDrawerViewController)
    func profileDrawerDidTapNews(_ drawer:              ProfileNavigationDrawerViewController)
    func profileDrawerDidTapShareInfoCard(_ drawer:     ProfileNavigationDrawerViewController)
    func profileDrawerDidTapHelp(_ drawer:              ProfileNavigationDrawerViewController)
    func profileDrawerDidTapLogout(_ drawer:            ProfileNavigationDrawerViewController)
    func profileDrawerDidTapClose(_ drawer:             ProfileNavigationDrawerViewController)
}

class ProfileNavigationDrawerViewController: UIViewController {
    weak var delegate: ProfileDrawerDelegate?
    private let drawerView = ProfileNavigationDrawerView()
    
    private var profileImageView: UIImageView {
        drawerView.profileImageView
    }
    
    private var nameLabel: UILabel{
        drawerView.nameLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wireCallbacks()
        refreshProfile()
    }
    
    override func loadView(){
        view = drawerView
    }
    
    private func wireCallbacks(){
        drawerView.onEditProfile = { [weak self] in
            guard let self = self else { return }
            self.delegate?.profileDrawerDidTapEditProfile(self)
        }
        
        drawerView.onProductHistory = { [weak self] in
            guard let self = self else { return }
            self.delegate?.profileDrawerDidTapProductHistory(self)
        }
        
        drawerView.onNews = { [weak self] in
            guard let self = self else { return }
            self.delegate?.profileDrawerDidTapNews(self)
        }
        
        drawerView.onShareCard = { [weak self] in
            guard let self = self else { return }
            self.delegate?.profileDrawerDidTapShareInfoCard(self)
        }
        
        drawerView.onHelp = { [weak self] in
            guard let self = self else { return }
            self.delegate?.profileDrawerDidTapHelp(self)
        }
        
        drawerView.onLogout = { [weak self] in
            self?.handleLogout()
        }
    }
    
    func refreshProfile(){
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchUserProfile(uid: uid) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    print("Drawer: failed to fetch profile:", err)
                case .success(let user):
                    self.nameLabel.text = user.name
                    
                    // Option A: use separate image fetch, same as ProfileSetupViewController
                    FirebaseService.shared.fetchProfileImage(uid: uid) { imageResult in
                        DispatchQueue.main.async {
                            switch imageResult {
                            case .success(let image):
                                if let image = image {
                                    self.profileImageView.image = image
                                    self.profileImageView.contentMode = .scaleAspectFill
                                } else {
                                    self.setPlaceholderImage()
                                }
                            case .failure(_):
                                self.setPlaceholderImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Set PlaceHolder image
    private func setPlaceholderImage(){
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.contentMode = .scaleAspectFit
    }
    
    private func handleLogout() {
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
            } else {
                self.navigationController?.setViewControllers([loginVC], animated: true)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "Error signing out: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
//            showAlert(title: "Error", message: "Failed to logout: \(error.localizedDescription)")
        }
    }
}
