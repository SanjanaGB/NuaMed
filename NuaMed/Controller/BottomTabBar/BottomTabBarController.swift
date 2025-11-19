import UIKit

class BottomTabBarController: UITabBarController, ProfileDrawerDelegate {
    //Drawer properties
    private let menuWidth: CGFloat = 280
    private let drawerVC = ProfileNavigationDrawerViewController()
    private let dimmingView = UIView()
    private var menuLeadingConstraint: NSLayoutConstraint!
    private var isMenuOpen = false
    
    //Keep reference to the "Profile" tab item: default to Search tab
    private weak var profileTabItem: UITabBarItem?
    private var lastSelectedIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        
        setupTabs()
        setupDrawer()
    }
    
    // MARK: - Tabs setup
    private func setupTabs() {
        // Dummy VC for Profile tab: it never actually shows content
        let profileDummyVC = UIViewController()
        profileDummyVC.view.backgroundColor = .systemBackground
        
        let searchVC = SearchViewController()
        let favoritesVC = FavoritesViewController()
        
        let searchNav = UINavigationController(rootViewController: searchVC)
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        
        // Profile tab item – acts as a button
        let profileItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        profileDummyVC.tabBarItem = profileItem
        self.profileTabItem = profileItem
        
        // Normal tabs
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )
        
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        viewControllers = [profileDummyVC, searchNav, favoritesNav]
        selectedIndex = 1          // start on Search
        lastSelectedIndex = 1
    }
    
    // MARK: - Drawer
    private func setupDrawer() {
        drawerVC.delegate = self
        
        addChild(drawerVC)
        view.addSubview(drawerVC.view)
        drawerVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Start fully off-screen to the left
        menuLeadingConstraint = drawerVC.view
            .leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
        
        NSLayoutConstraint.activate([
            drawerVC.view.widthAnchor.constraint(equalToConstant: menuWidth),
            drawerVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            drawerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuLeadingConstraint
        ])
        
        drawerVC.didMove(toParent: self)
        // Dimming overlay
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        view.insertSubview(dimmingView, belowSubview: drawerVC.view)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        dimmingView.addGestureRecognizer(tap)
    }
    
    // Open drawer instead of switching to profile tab
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let profileItem = profileTabItem else { return }
        
        if item == profileItem {
            // Revert selection back to the last real tab
            selectedIndex = lastSelectedIndex
            toggleMenu()
        } else {
            // Normal tab selection – remember it
            lastSelectedIndex = selectedIndex
        }
    }
    
    @objc private func toggleMenu() {
        isMenuOpen.toggle()
        menuLeadingConstraint.constant = isMenuOpen ? 0 : -menuWidth
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.view.layoutIfNeeded()
            self.dimmingView.alpha = self.isMenuOpen ? 1 : 0
        })
    }
    
    // MARK: - ProfileDrawerDelegate
    func profileDrawerDidTapClose(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
    }
    
    func profileDrawerDidTapEditProfile(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        // Example: push edit screen on the currently selected nav controller
        if let nav = selectedViewController as? UINavigationController {
            // nav.pushViewController(EditProfileViewController(), animated: true)
            print("Edit profile tapped")
        }
    }
    
    func profileDrawerDidTapProductHistory(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        print("Product history tapped")
    }
    
    func profileDrawerDidTapNews(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        print("News tapped")
    }
    
    func profileDrawerDidTapShareInfoCard(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        print("Share info card tapped")
    }
    
    func profileDrawerDidTapHelp(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        print("Help tapped")
    }
    
    func profileDrawerDidTapLogout(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        print("Logout tapped")
    }
}
