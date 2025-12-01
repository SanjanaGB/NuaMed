import UIKit

class BottomTabBarController: UITabBarController, ProfileDrawerDelegate {
    //Drawer properties
    private let menuWidth: CGFloat = 280
    private let drawerVC = ProfileNavigationDrawerViewController()
    private let dimmingView = UIView()
    private var menuLeadingConstraint: NSLayoutConstraint!
    private var isMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        
        delegate = self
        
        setupTabs()
        setupDrawer()
    }
    
    //MARK: tabs setup
    private func setupTabs() {
        //MARK: dummy VC for Profile tab: it never shows an actual content
        let profileDummyVC = UIViewController()
        profileDummyVC.view.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        
        //Profile tab item
        let profileItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: nil
        )
        
        profileDummyVC.tabBarItem = profileItem
        
        //MARK: Real tabs
        //Search tab
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )
        
        //Favorites tab
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        //Assign the tab to the bottom tab bar controller
        viewControllers = [profileDummyVC, searchNav, favoritesNav]
        selectedIndex = 1          // start the main app page on Search
    }
    
    //MARK: drawer setup
    private func setupDrawer() {
        drawerVC.delegate = self
        
        addChild(drawerVC)
        view.addSubview(drawerVC.view)
        drawerVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        //Start fully off-screen to the left
        menuLeadingConstraint = drawerVC.view
            .leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: -menuWidth)   //hide the navigation drawer all the way to the left
        
        NSLayoutConstraint.activate([
            drawerVC.view.widthAnchor.constraint(equalToConstant: menuWidth),
            drawerVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            drawerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuLeadingConstraint
        ])
        
        drawerVC.didMove(toParent: self)
        
        //Dimming overlay
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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
    
    @objc private func toggleMenu() {
        isMenuOpen.toggle()
        
        //Get latest name and avatar
        if isMenuOpen {
            drawerVC.refreshProfile()
        }
        
        menuLeadingConstraint.constant = isMenuOpen ? 0 : -menuWidth
        
        view.bringSubviewToFront(dimmingView)
        view.bringSubviewToFront(drawerVC.view)
        
        //Navigation drawer animation
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            self.dimmingView.alpha = self.isMenuOpen ? 1 : 0
        })
    }
    
    //MARK: ProfileDrawerDelegate
    func profileDrawerDidTapClose(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
    }

    func profileDrawerDidTapEditProfile(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
        guard let nav = selectedViewController as? UINavigationController else {
            return
        }
        
        let viewC = ProfileSetupViewController()
        viewC.hidesBottomBarWhenPushed = true
        nav.pushViewController(viewC, animated: true)
    }
    
    func profileDrawerDidTapProductHistory(_ drawer: ProfileNavigationDrawerViewController) {
        toggleMenu()
//        guard let nav = selectedViewController as? UINavigationController else {
//            return
//        }
//        
//        let viewC = ProductHistoryViewController()
//        viewC.hidesBottomBarWhenPushed = true
//        nav.pushViewController(viewC, animated: true)
        let historyVC = ProductHistoryViewController()
        let nav = UINavigationController(rootViewController: historyVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        // Force the tab bar to sit flush at the bottom and span full width
//        var frame = tabBar.frame
//        frame.origin.x = 0
////        frame.size.width = view.bounds.width
//        frame.origin.y = view.bounds.height - frame.size.height
//        tabBar.frame = frame
    }
    
}

//Open drawer instead of switching to profile tab
extension BottomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let viewControllerS = tabBarController.viewControllers,
              let index = viewControllerS.firstIndex(of: viewController) else {
            return true
        }
        
        //Condition: if a user clicks on the Profile tab, then open the drawer instead of switching to a tab
        //In this case the current tab remains active
        if index == 0 {
            toggleMenu()
            return false
        }
        
        //Other tabs have a 'normal' tab switching functionality
        return true
    }
}
