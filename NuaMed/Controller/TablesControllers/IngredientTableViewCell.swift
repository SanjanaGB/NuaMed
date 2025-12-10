import UIKit

final class IngredientTableViewCell: UITableViewCell {
    // Left status icon
    private let statusImageView = UIImageView()
    private let nameLabel = UILabel()
    private let infoButton = UIButton(type: .system)
    private let separatorView = UIView()

    // Callback so the VC can respond when user taps the info button
    var onInfoTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoButton)

        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)

        // SF Symbol for the info button
        let infoImage = UIImage(systemName: "info.circle")
        infoButton.setImage(infoImage, for: .normal)

        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 22),
            statusImageView.heightAnchor.constraint(equalToConstant: 22),

            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 24),
            infoButton.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        //Adding a light gray line for a better visibility
        separatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
                separatorView.heightAnchor.constraint(equalToConstant: 0.5),
                separatorView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: infoButton.trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc private func infoButtonTapped() {
        onInfoTapped?()
    }

    // MARK: - Public configuration
    func configure(with ingredient: Ingredient) {
        nameLabel.text = ingredient.name

        // If there's no extra info text, hide the info button
        let hasDetails = !ingredient.infoText.isEmpty
        infoButton.isHidden = !hasDetails

        // Choose icon + tint based on safety, matching your screenshot idea
        let imageName: String
        let tint: UIColor

        switch ingredient.safety {
        case .safe:
            imageName = "checkmark.circle.fill"
            tint = .systemGreen
        case .unsafe:
            imageName = "slash.circle.fill"
            tint = .systemRed
        case .caution:
            imageName = "exclamationmark.circle.fill"
            tint = .systemYellow
        }

        statusImageView.image = UIImage(systemName: imageName)
        statusImageView.tintColor = tint
    }
}
