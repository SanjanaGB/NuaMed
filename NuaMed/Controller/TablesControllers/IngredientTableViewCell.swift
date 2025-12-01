import UIKit

class IngredientTableViewCell: UITableViewCell {

    private let statusImageView = UIImageView()
    private let nameLabel = UILabel()
    private let infoButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Status icon (left)
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        contentView.addSubview(statusImageView)

        // Ingredient name (middle)
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        // Info icon (right)
        let infoImage = UIImage(systemName: "info.circle")
        infoButton.setImage(infoImage, for: .normal)
        infoButton.tintColor = .darkGray
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 24),
            statusImageView.heightAnchor.constraint(equalToConstant: 24),

            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 24),
            infoButton.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with ingredient: Ingredient) {
        nameLabel.text = ingredient.name
        
        let baseConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        switch ingredient.safety {
        case .safe:
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: baseConfig)
            statusImageView.tintColor = .systemGreen

        case .unsafe:
            statusImageView.image = UIImage(systemName: "xmark.circle.fill", withConfiguration: baseConfig)
            statusImageView.tintColor = .systemRed

        case .caution:
            statusImageView.image = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: baseConfig)
            statusImageView.tintColor = .systemOrange
        }
    }
}
