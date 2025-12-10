import UIKit

class ProfileNavigationDrawerView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let logoutButton = UIButton(type: .system)
    
    //Callback on button taps in the navigation drawer
    var onEditProfile: (() -> Void)?
    var onProductHistory: (() -> Void)?
    var onNews: (() -> Void)?
    var onShareCard: (() -> Void)?
    var onHelp: (() -> Void)?
    var onLogout: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init? (coder: NSCoder){
        super.init (coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        backgroundColor = .clear
        isOpaque = false
        setupHeaderAndMenu()
    }
    
    private func setupHeaderAndMenu(){
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        //Profile image and name
        let avatarSize: CGFloat = 80
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        profileImageView.layer.cornerRadius = avatarSize / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.text = "User Name"
        
        //MARK: Header stack
        let headerStack = UIStackView(arrangedSubviews: [profileImageView, nameLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 8
        
        //MARK: BUTTONS + FUNCTIONALITIES
        //Edit profile
        let editButton = makeMenuButton(title: "    Edit User Profile", systemImage: "person")
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        //History
        let productHistoryButton = makeMenuButton(title: "   Product history",
                                                  systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
        productHistoryButton.addTarget(self, action: #selector(productHistoryTapped), for: .touchUpInside)
        
        //News
//        let newsButton = makeMenuButton(title: "   Related news", systemImage: "newspaper")
//        newsButton.addTarget(self, action: #selector(newsTapped), for: .touchUpInside)
//        
        //Share my information card
//        let shareCardButton = makeMenuButton(title: "   Share my card", systemImage: "person.text.rectangle.fill")
//        shareCardButton.addTarget(self, action: #selector(shareCardTapped), for: .touchUpInside)
//        
        //Help
//        let helpButton = makeMenuButton(title: "   Help", systemImage: "questionmark.circle")
//        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        
        //Logout button
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemBlue
        logoutButton.layer.cornerRadius = 8
        logoutButton.layer.masksToBounds = true
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        //MARK: Navigation Drawer Layout
        let stack = UIStackView(arrangedSubviews: [
            headerStack,
            UIView(),
            makeSeparator(),
            editButton,
            productHistoryButton,
            //newsButton,
            //shareCardButton,
            makeSeparator(),
            //helpButton,
            UIView(), //spacer
        ])
        
        //Stack adjustments
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill  //matches the stack's width
        stack.distribution = .fill
        
        addSubview(stack)
        addSubview(logoutButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Stack
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 106),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            
            //Making sure that the stack doesn't overlap with the logout button
            stack.bottomAnchor.constraint(lessThanOrEqualTo: logoutButton.topAnchor, constant: -24)
        ])
        
        //Logout button
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 140),
        ])
    }
    
    //MARK: Helper functions
    //Common parameters for each button in the drawer
    private func makeMenuButton(title: String, systemImage: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: systemImage), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        return button
    }
    
    //Separator
    private func makeSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = .systemGray4
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ line.heightAnchor.constraint(equalToConstant: 1.0) ])
        return line
    }
    
    // MARK: - Actions
    @objc private func editProfileTapped()   { onEditProfile?() }
    @objc private func productHistoryTapped(){ onProductHistory?() }
//    @objc private func newsTapped()          { onNews?() }
//    @objc private func shareCardTapped()     { onShareCard?() }
//    @objc private func helpTapped()          { onHelp?() }
    @objc private func logoutTapped()        { onLogout?()}
}
