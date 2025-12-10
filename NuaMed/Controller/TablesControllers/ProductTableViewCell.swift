import UIKit

class ProductTableViewCell: UITableViewCell {
    // MARK: - Subviews
    private let cardView = UIView()
    let itemImageView = UIImageView()
    let nameLabel = UILabel()
    private let scoreBackgroundView = UIView()
    let safetyIndexLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card view (white rounded background)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Product image on the left
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(itemImageView)

        // Name label in the middle
        nameLabel.font = .systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)

        // Pill background (behind the score)
        scoreBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        scoreBackgroundView.layer.cornerRadius = 14
        scoreBackgroundView.layer.masksToBounds = true
        cardView.addSubview(scoreBackgroundView)

        // Score label inside the pill
        safetyIndexLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        safetyIndexLabel.textAlignment = .center
        safetyIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyIndexLabel.setContentHuggingPriority(.required, for: .horizontal)
        safetyIndexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        scoreBackgroundView.addSubview(safetyIndexLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Card: inset inside the cell → gives separation between rows
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            // Image on the left
            itemImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 44),
            itemImageView.heightAnchor.constraint(equalToConstant: 44),

            // Pill on the right
            scoreBackgroundView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            scoreBackgroundView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            scoreBackgroundView.heightAnchor.constraint(equalToConstant: 28),

            safetyIndexLabel.leadingAnchor.constraint(equalTo: scoreBackgroundView.leadingAnchor, constant: 10),
            safetyIndexLabel.trailingAnchor.constraint(equalTo: scoreBackgroundView.trailingAnchor, constant: -10),
            safetyIndexLabel.topAnchor.constraint(equalTo: scoreBackgroundView.topAnchor, constant: 4),
            safetyIndexLabel.bottomAnchor.constraint(equalTo: scoreBackgroundView.bottomAnchor, constant: -4),

            // Name between image and pill
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreBackgroundView.leadingAnchor, constant: -12),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        nameLabel.text = nil
        safetyIndexLabel.text = nil
    }

    // MARK: - Configure (same signature you already use)
    func configure(image: UIImage? = nil, name: String, safetyIndex: String) {
        itemImageView.image = image ?? UIImage(systemName: "photo.circle.fill")
        nameLabel.text = name
        safetyIndexLabel.text = safetyIndex

        let score = Int(safetyIndex) ?? 0
        updateScoreAppearance(score: score)
    }

    private func updateScoreAppearance(score: Int) {
        switch score {
        case ..<30:
            scoreBackgroundView.backgroundColor = .systemRed
            safetyIndexLabel.textColor = .white
        case 30..<60:
            scoreBackgroundView.backgroundColor = .systemYellow
            safetyIndexLabel.textColor = .black
        default:
            scoreBackgroundView.backgroundColor = .systemGreen
            safetyIndexLabel.textColor = .white
        }
    }
}
