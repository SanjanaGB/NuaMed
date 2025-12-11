import UIKit

class ProductInfoView: UIView {

    // ---------------------------------------------------------------------
    // MARK: - UI COMPONENTS
    // ---------------------------------------------------------------------

    // ❌ REMOVED BACK BUTTON

    let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.tintColor = .yellow
        btn.backgroundColor = .clear
        return btn
    }()

    let productNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    let safetyCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 40
        return view
    }()

    let safetyScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()

    let alertsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.systemYellow
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.setTitle("View Safety Alerts", for: .normal)
        btn.layer.cornerRadius = 14
        return btn
    }()

    let ingredientsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    let ingredientsTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorInset = .zero
        table.rowHeight = 52
        table.separatorStyle = .singleLine
        return table
    }()

    // ---------------------------------------------------------------------
    // MARK: CALLBACK HANDLERS
    // ---------------------------------------------------------------------

    var onFavoriteTapped: (() -> Void)?
    var onAlertsTapped: (() -> Void)?

    // ---------------------------------------------------------------------
    // MARK: - INIT
    // ---------------------------------------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemBlue
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ---------------------------------------------------------------------
    // MARK: - CONFIGURE
    // ---------------------------------------------------------------------

    func configure(name: String,
                   safetyScore: Int,
                   allergens: [String],
                   pillColor: UIColor,
                   category: String) {

        productNameLabel.text = name
        categoryLabel.text = "Category: \(category)"
        safetyScoreLabel.text = "\(safetyScore)"
        safetyCircle.backgroundColor = pillColor

        alertsButton.setTitle("View Safety Alerts (\(allergens.count))", for: .normal)
    }

    func updateFavoriteStarIcon(systemName: String) {
        favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
    }

    // ---------------------------------------------------------------------
    // MARK: - LAYOUT
    // ---------------------------------------------------------------------

    private func setupUI() {

        addSubview(favoriteButton)
        addSubview(productNameLabel)
        addSubview(categoryLabel)
        addSubview(safetyCircle)
        safetyCircle.addSubview(safetyScoreLabel)
        addSubview(alertsButton)
        addSubview(ingredientsContainer)
        ingredientsContainer.addSubview(ingredientsTableView)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyCircle.translatesAutoresizingMaskIntoConstraints = false
        safetyScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        alertsButton.translatesAutoresizingMaskIntoConstraints = false
        ingredientsContainer.translatesAutoresizingMaskIntoConstraints = false
        ingredientsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // ⭐ ONLY FAVORITE BUTTON AT TOP
            favoriteButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),

            // PRODUCT NAME
            productNameLabel.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 20),
            productNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            // CATEGORY
            categoryLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),

            // SAFETY CIRCLE
            safetyCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            safetyCircle.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            safetyCircle.widthAnchor.constraint(equalToConstant: 80),
            safetyCircle.heightAnchor.constraint(equalToConstant: 80),

            safetyScoreLabel.centerXAnchor.constraint(equalTo: safetyCircle.centerXAnchor),
            safetyScoreLabel.centerYAnchor.constraint(equalTo: safetyCircle.centerYAnchor),

            // ALERTS BUTTON
            alertsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            alertsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            alertsButton.topAnchor.constraint(equalTo: safetyCircle.bottomAnchor, constant: 20),
            alertsButton.heightAnchor.constraint(equalToConstant: 48),

            // INGREDIENT CONTAINER
            ingredientsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ingredientsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ingredientsContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            ingredientsContainer.topAnchor.constraint(equalTo: alertsButton.bottomAnchor, constant: 16),

            // TABLE INSIDE CONTAINER
            ingredientsTableView.topAnchor.constraint(equalTo: ingredientsContainer.topAnchor),
            ingredientsTableView.bottomAnchor.constraint(equalTo: ingredientsContainer.bottomAnchor),
            ingredientsTableView.leadingAnchor.constraint(equalTo: ingredientsContainer.leadingAnchor),
            ingredientsTableView.trailingAnchor.constraint(equalTo: ingredientsContainer.trailingAnchor)
        ])

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        alertsButton.addTarget(self, action: #selector(alertsTapped), for: .touchUpInside)
    }

    // ---------------------------------------------------------------------
    // MARK: - ACTIONS
    // ---------------------------------------------------------------------

    @objc private func favoriteTapped() { onFavoriteTapped?() }
    @objc private func alertsTapped() { onAlertsTapped?() }
}
