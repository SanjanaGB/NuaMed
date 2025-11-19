import UIKit

final class DropdownMenuView: UIView {
    private let button = UIButton(type: .system)
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.down"))
    private var categories: [String] = []

    //Call this when a user picks a category
    var onCategorySelected: ((String) -> Void)?

    init(categories: [String], initialTitle: String? = nil) {
        super.init(frame: .zero)
        self.categories = categories
        
        setupButton()
        setupChevron()
        configureMenu()
        
        setTitle(initialTitle ?? categories.first ?? "Select category")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupChevron()
    }

    //Button itself
    private func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        //Open the dropdown by tapping on it
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false

        addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 36)
        ])

        // Optional: background to look like a pill
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    private func setupChevron(){
        //Add a small chevron on the right
        let chevron = UIImage(systemName: "chevron.down")
        //        chevronView.setImage(chevron, for: .normal)
        chevronView.tintColor = .white
        chevronView.contentMode = .scaleAspectFit
        chevronView.isUserInteractionEnabled = false
        chevronView.semanticContentAttribute = .forceRightToLeft
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chevronView)
        
        NSLayoutConstraint.activate([
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            //How far do we want to see the chevron
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    private func configureMenu() {
        guard !categories.isEmpty else { return }

        let actions = categories.map { [weak self] title in
            UIAction(title: title) { _ in
                self?.setTitle(title)
                self?.onCategorySelected?(title)
            }
        }

        button.menu = UIMenu(title: "", children: actions)
    }

    private func setTitle(_ title: String) {
        button.setTitle(title, for: .normal)
    }

    //Category update
    func updateCategories(_ newCategories: [String]) {
        categories = newCategories
        configureMenu()
    }
}
