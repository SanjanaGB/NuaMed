import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // You can build this with stack views / buttons / table view
        // Here’s the minimal skeleton with some buttons:
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        let editButton = makeMenuButton(title: "Edit User Profile", systemImage: "person")
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        let productHistoryButton = makeMenuButton(title: "Product history", systemImage: "tag")
        productHistoryButton.addTarget(self, action: #selector(productHistoryTapped), for: .touchUpInside)
        
        let newsButton = makeMenuButton(title: "News", systemImage: "newspaper")
        newsButton.addTarget(self, action: #selector(newsTapped), for: .touchUpInside)
        
        let shareCardButton = makeMenuButton(title: "Share my information card",
                                             systemImage: "person.2")
        
        shareCardButton.addTarget(self, action: #selector(shareCardTapped), for: .touchUpInside)
        
        let helpButton = UIButton(type: .system)
        helpButton.setTitle("Help", for: .normal)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        
        
        
        //Layout
        let stack = UIStackView(arrangedSubviews: [
            closeButton,
            editButton,
            productHistoryButton,
            newsButton,
            shareCardButton,
            UIView(),    // spacer
            helpButton,
            logoutButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    private func makeMenuButton(title: String, systemImage: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(systemName: systemImage), for: .normal)
        btn.tintColor = .black
        btn.contentHorizontalAlignment = .left
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        return btn
    }
    
    // MARK: - Actions
    @objc private func closeTapped()         { delegate?.profileDrawerDidTapClose(self) }
    @objc private func editProfileTapped()   { delegate?.profileDrawerDidTapEditProfile(self) }
    @objc private func productHistoryTapped(){ delegate?.profileDrawerDidTapProductHistory(self) }
    @objc private func newsTapped()          { delegate?.profileDrawerDidTapNews(self) }
    @objc private func shareCardTapped()     { delegate?.profileDrawerDidTapShareInfoCard(self) }
    @objc private func helpTapped()          { delegate?.profileDrawerDidTapHelp(self) }
    @objc private func logoutTapped()        { delegate?.profileDrawerDidTapLogout(self) }
}
