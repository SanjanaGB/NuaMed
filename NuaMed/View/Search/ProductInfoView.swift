import UIKit

class ProductInfoView: UIView {

    // MARK: - Top UI
    var productImageView: UIImageView!
    var productNameLabel: UILabel!
    var safetyRatingLabel: UILabel!
    var safetyPillView: UIView!
    var safetyLabel: UILabel!
    var safetyIndexLabel: UILabel!
    var favoriteStarImageView: UIImageView!
    var onFavoriteTapped: (() -> Void)?

    // MARK: - Allergens Card
    var rectangleContainer: UIView!
    var allergensIconView: UIImageView!
    var allergensTitleLabel: UILabel!
    var allergensBodyLabel: UILabel!

    // MARK: - Ingredients Card
    let ingredientsCardView = UIView()
    let ingredientsLabel = UILabel()
    let ingredientsTableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBlue

        setupProductImageView()
        setupFavoriteStarIcon()
        setupProductNameLabel()
        setupSafetyRatingLabel()
        setupSafetyPill()

        setupAllergensCard()

        setupIngredientsCard()
        setupIngredientsLabel()
        setupIngredientsTable()

        initConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - CONFIGURE DATA
    func configure(name: String, safetyScore: Int, allergens: [String], pillColor: UIColor?) {
        productNameLabel.text = name
        safetyIndexLabel.text = "\(safetyScore)"
        allergensBodyLabel.text = allergens.joined(separator: "\n")

        let style = ProductInfoView.safetyStyle(for: safetyScore)

        safetyPillView.backgroundColor = pillColor ?? style.background
        safetyLabel.textColor = style.text
        safetyIndexLabel.textColor = style.text
    }

    // MARK: - SETUP TOP UI
    func setupProductImageView() {
        productImageView = UIImageView()
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 40
        productImageView.clipsToBounds = true
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(productImageView)
    }

    func setupFavoriteStarIcon() {
        favoriteStarImageView = UIImageView(image: UIImage(systemName: "star"))
        favoriteStarImageView.tintColor = .systemYellow
        favoriteStarImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteStarImageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteStarTapped))
        favoriteStarImageView.addGestureRecognizer(tap)
        addSubview(favoriteStarImageView)
    }

    func setupProductNameLabel() {
        productNameLabel = UILabel()
        productNameLabel.text = "Product Name"
        productNameLabel.font = .boldSystemFont(ofSize: 28)
        productNameLabel.textColor = .white
        productNameLabel.textAlignment = .center
        productNameLabel.numberOfLines = 0
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(productNameLabel)
    }

    func setupSafetyRatingLabel() {
        safetyRatingLabel = UILabel()
        safetyRatingLabel.text = "Safety Rating:"
        safetyRatingLabel.font = .boldSystemFont(ofSize: 20)
        safetyRatingLabel.textColor = .white
        safetyRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyRatingLabel)
    }

    func setupSafetyPill() {
        safetyPillView = UIView()
        safetyPillView.backgroundColor = .systemGreen
        safetyPillView.layer.cornerRadius = 16
        safetyPillView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyPillView)

        safetyLabel = UILabel()
        safetyLabel.text = "Safety"
        safetyLabel.font = .boldSystemFont(ofSize: 17)
        safetyLabel.textColor = .white
        safetyLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyPillView.addSubview(safetyLabel)

        safetyIndexLabel = UILabel()
        safetyIndexLabel.text = "80"
        safetyIndexLabel.font = .boldSystemFont(ofSize: 18)
        safetyIndexLabel.textColor = .white
        safetyIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyPillView.addSubview(safetyIndexLabel)
    }

    // MARK: - ALLERGEN CARD
    func setupAllergensCard() {
        rectangleContainer = UIView()
        rectangleContainer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.92)
        rectangleContainer.layer.cornerRadius = 22
        rectangleContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rectangleContainer)

        allergensIconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        allergensIconView.tintColor = .black
        allergensIconView.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensIconView)

        allergensTitleLabel = UILabel()
        allergensTitleLabel.text = "Allergens"
        allergensTitleLabel.font = .boldSystemFont(ofSize: 20)
        allergensTitleLabel.textColor = .black
        allergensTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensTitleLabel)

        allergensBodyLabel = UILabel()
        allergensBodyLabel.font = .systemFont(ofSize: 16)
        allergensBodyLabel.textColor = .black
        allergensBodyLabel.numberOfLines = 0
        allergensBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensBodyLabel)
    }

    // MARK: - INGREDIENTS CARD
    func setupIngredientsCard() {
        ingredientsCardView.backgroundColor = .white
        ingredientsCardView.layer.cornerRadius = 24
        ingredientsCardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ingredientsCardView)
    }

    func setupIngredientsLabel() {
        ingredientsLabel.text = "Natural & Artificial Ingredients"
        ingredientsLabel.font = .boldSystemFont(ofSize: 20)
        ingredientsLabel.textAlignment = .center
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        ingredientsCardView.addSubview(ingredientsLabel)
    }

    func setupIngredientsTable() {
        ingredientsTableView.backgroundColor = .clear
        ingredientsTableView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsCardView.addSubview(ingredientsTableView)
    }

    // MARK: - CONSTRAINTS
    func initConstraints() {
        NSLayoutConstraint.activate([

            // Top image
            productImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 28),
            productImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),

            // Star
            favoriteStarImageView.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            favoriteStarImageView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 16),

            // Name
            productNameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            productNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            productNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Safety row
            safetyRatingLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 18),
            safetyRatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),

            safetyPillView.centerYAnchor.constraint(equalTo: safetyRatingLabel.centerYAnchor),
            safetyPillView.leadingAnchor.constraint(equalTo: safetyRatingLabel.trailingAnchor, constant: 10),
            safetyPillView.heightAnchor.constraint(equalToConstant: 30),

            safetyLabel.leadingAnchor.constraint(equalTo: safetyPillView.leadingAnchor, constant: 10),
            safetyLabel.centerYAnchor.constraint(equalTo: safetyPillView.centerYAnchor),

            safetyIndexLabel.leadingAnchor.constraint(equalTo: safetyLabel.trailingAnchor, constant: 6),
            safetyIndexLabel.trailingAnchor.constraint(equalTo: safetyPillView.trailingAnchor, constant: -10),
            safetyIndexLabel.centerYAnchor.constraint(equalTo: safetyPillView.centerYAnchor),

            // Allergen Card
            rectangleContainer.topAnchor.constraint(equalTo: safetyRatingLabel.bottomAnchor, constant: 24),
            rectangleContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rectangleContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            allergensIconView.topAnchor.constraint(equalTo: rectangleContainer.topAnchor, constant: 14),
            allergensIconView.leadingAnchor.constraint(equalTo: rectangleContainer.leadingAnchor, constant: 14),

            allergensTitleLabel.centerYAnchor.constraint(equalTo: allergensIconView.centerYAnchor),
            allergensTitleLabel.leadingAnchor.constraint(equalTo: allergensIconView.trailingAnchor, constant: 8),

            allergensBodyLabel.topAnchor.constraint(equalTo: allergensIconView.bottomAnchor, constant: 10),
            allergensBodyLabel.leadingAnchor.constraint(equalTo: rectangleContainer.leadingAnchor, constant: 14),
            allergensBodyLabel.trailingAnchor.constraint(equalTo: rectangleContainer.trailingAnchor, constant: -14),
            allergensBodyLabel.bottomAnchor.constraint(equalTo: rectangleContainer.bottomAnchor, constant: -14),

            // Ingredients card
            ingredientsCardView.topAnchor.constraint(equalTo: rectangleContainer.bottomAnchor, constant: 20),
            ingredientsCardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ingredientsCardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ingredientsCardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),

            ingredientsLabel.topAnchor.constraint(equalTo: ingredientsCardView.topAnchor, constant: 16),
            ingredientsLabel.leadingAnchor.constraint(equalTo: ingredientsCardView.leadingAnchor, constant: 16),
            ingredientsLabel.trailingAnchor.constraint(equalTo: ingredientsCardView.trailingAnchor, constant: -16),

            ingredientsTableView.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor, constant: 8),
            ingredientsTableView.leadingAnchor.constraint(equalTo: ingredientsCardView.leadingAnchor),
            ingredientsTableView.trailingAnchor.constraint(equalTo: ingredientsCardView.trailingAnchor),
            ingredientsTableView.bottomAnchor.constraint(equalTo: ingredientsCardView.bottomAnchor)
        ])
    }

    // MARK: - Favorite Tap
    @objc func favoriteStarTapped() {
        onFavoriteTapped?()
    }
    
    func updateFavoriteStarIcon(systemName: String) {
        favoriteStarImageView.image = UIImage(systemName: systemName)
    }
}

private extension ProductInfoView {
    struct SafetyStyle {
        let background: UIColor
        let text: UIColor
    }

    static func safetyStyle(for score: Int) -> SafetyStyle {
        switch score {
        case ..<40:
            return SafetyStyle(background: .systemRed, text: .white)
        case 40..<70:
            return SafetyStyle(background: .systemYellow, text: .black)
        default:
            return SafetyStyle(background: .systemGreen, text: .white)
        }
    }
}
