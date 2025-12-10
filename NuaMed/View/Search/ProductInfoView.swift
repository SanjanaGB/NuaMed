import UIKit

class ProductInfoView: UIView {
    let titleLabel = UILabel()
    let ingredientsCardView = UIView()
    
    var productImageView: UIImageView!
    var productNameLabel: UILabel!
    
    var safetyPillView: UIView!
    var safetyRatingLabel: UILabel!
    var safetyLabel: UILabel!
    var safetyIndexLabel: UILabel!
    
    //Favorites star icon
    var favoriteStarImageView: UIImageView!
    var onFavoriteTapped: (() -> Void)?
    
    //Alergens yellow card
    var rectangleContainer: UIView!
    var allergensTitleLabel: UILabel!
    var ingredientsLabel: UILabel!
    var allergensIconView: UIImageView!
    var allergensBodyLabel: UILabel!
    
    //Table of ingredients
    let ingredientsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray

        //Top 1/3 view
        setupProductImageView()
        setupFavoriteStarIcon()
        setupProductNameLabel()
        setupSafetyRatingLabel()
        setupSafetyPill()
        
        //Middle 2/3 view
        setupAllergensCard()
        
        //Bottom 3/3 view: table of ingredients
        setupIngredientsTableView()
        setupIngredientsLabel()
        initConstraints()
    }
    
    func configure(name: String, safetyScore: Int, allergens: [String], pillColor: UIColor? = nil) {
        productNameLabel.text = name
        safetyIndexLabel.text = "\(safetyScore)"
        allergensBodyLabel.text = allergens.joined(separator: "\n")
        
        let style = ProductInfoView.safetyStyle(for: safetyScore)
        
        // If a pillColor is passed from Search, use that.
        // Otherwise fall back to style.background.
        let background = pillColor ?? style.background
        safetyPillView.backgroundColor = background
        
        if let color = pillColor {
            safetyPillView.backgroundColor = color
            
            //Adjust text colors based on the pill color
            if color == .systemYellow {
                safetyLabel.textColor = .black
                safetyIndexLabel.textColor = .black
            } else {
                safetyLabel.textColor = .white
                safetyIndexLabel.textColor = .white
            }
        } else {
            let style = ProductInfoView.safetyStyle(for: safetyScore)
            safetyPillView.backgroundColor = style.background
            safetyLabel.textColor = style.text
            safetyIndexLabel.textColor = style.text
        }
    }
    
    //Top 1/3 view
    func setupProductImageView(){
        productImageView = UIImageView()
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = 50
        productImageView.clipsToBounds = true
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(productImageView)
    }
    
    func setupFavoriteStarIcon() {
        favoriteStarImageView = UIImageView()
        favoriteStarImageView.image = UIImage(systemName: "star")
        favoriteStarImageView.tintColor = .systemYellow
        favoriteStarImageView.translatesAutoresizingMaskIntoConstraints = false

        //Clickable star
        favoriteStarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteStarTapped))
        favoriteStarImageView.addGestureRecognizer(tap)
        addSubview(favoriteStarImageView)
    }
    
    func setupProductNameLabel(){
        productNameLabel = UILabel()
        productNameLabel.text = "Product Name"
        productNameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        productNameLabel.textColor = .white
        productNameLabel.textAlignment = .center
        productNameLabel.numberOfLines = 0
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(productNameLabel)
    }
    
    func setupSafetyRatingLabel(){
        safetyRatingLabel = UILabel()
        safetyRatingLabel.text = "Safety Rating: "
        safetyRatingLabel.textAlignment = .center
        safetyRatingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        safetyRatingLabel.textColor = .white
        safetyRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyRatingLabel)
    }
    
    func setupSafetyPill(){
        safetyPillView = UIView()
        safetyPillView.backgroundColor = .systemGreen
        safetyPillView.layer.cornerRadius = 16
        safetyPillView.clipsToBounds = true
        safetyPillView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyPillView)
        //Safety + Score view
        safetyLabel = UILabel()
        safetyLabel.text = "Safety"
        safetyLabel.font = UIFont.boldSystemFont(ofSize: 17)
        safetyLabel.textColor = .white
        safetyLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyPillView.addSubview(safetyLabel)
        
        safetyIndexLabel = UILabel()
        safetyIndexLabel.text = "75"
        safetyIndexLabel.font = UIFont.boldSystemFont(ofSize: 18)
        safetyIndexLabel.textColor = .white
        safetyIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        safetyPillView.addSubview(safetyIndexLabel)
    }
    
    //Middle 2/3 view
    func setupAllergensCard(){
        rectangleContainer = UIView()
        rectangleContainer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.9)
        rectangleContainer.layer.cornerRadius = 24
        rectangleContainer.clipsToBounds = true
        rectangleContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rectangleContainer)
        
        allergensIconView = UIImageView()
        allergensIconView.image = UIImage(systemName: "exclamationmark.triangle")
        allergensIconView.tintColor = .black
        allergensIconView.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensIconView)
        
        allergensTitleLabel = UILabel()
        allergensTitleLabel.text = "Allergens"
        allergensTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        allergensTitleLabel.textColor = .black
        allergensTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensTitleLabel)
        
        allergensBodyLabel = UILabel()
        allergensBodyLabel.text = "Perfume\nBenzyl Alcochol"
        allergensBodyLabel.font = UIFont.systemFont(ofSize: 16)
        allergensBodyLabel.numberOfLines = 0
        allergensBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        rectangleContainer.addSubview(allergensBodyLabel)
    }
    
    //Bottom 3/3 view: table of ingredients
    func setupIngredientsTableView() {
        ingredientsCardView.backgroundColor = .white
        ingredientsCardView.layer.cornerRadius = 24
        ingredientsCardView.clipsToBounds = true
        ingredientsCardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ingredientsCardView)
        
        // Configure the table INSIDE the card
        ingredientsTableView.tableFooterView = UIView()
        ingredientsTableView.register(IngredientTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        ingredientsTableView.isScrollEnabled = true
        ingredientsTableView.clipsToBounds = true
        ingredientsTableView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsTableView.backgroundColor = .clear
        ingredientsCardView.addSubview(ingredientsTableView)
    }
    
    func setupIngredientsLabel(){
        ingredientsLabel = UILabel()
        ingredientsLabel.text = "Natural & Artificial Ingredients"
        ingredientsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        ingredientsLabel.textColor = .black
        ingredientsLabel.textAlignment = .center
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        ingredientsCardView.addSubview(ingredientsLabel)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            productImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),
            
            //Star
            favoriteStarImageView.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 1),
            favoriteStarImageView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 64),
            favoriteStarImageView.widthAnchor.constraint(equalToConstant: 24),
            favoriteStarImageView.heightAnchor.constraint(equalToConstant: 24),
            
            //Product name
            productNameLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 1),
            productNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            productNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        
            //Safety row
            safetyRatingLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 24),
            safetyRatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
                        
            safetyPillView.centerYAnchor.constraint(equalTo: safetyRatingLabel.centerYAnchor),
            safetyPillView.leadingAnchor.constraint(equalTo: safetyRatingLabel.trailingAnchor, constant: 12),
            safetyPillView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            safetyPillView.heightAnchor.constraint(equalToConstant: 32),
            
            safetyLabel.leadingAnchor.constraint(equalTo: safetyPillView.leadingAnchor, constant: 12),
            safetyLabel.centerYAnchor.constraint(equalTo: safetyPillView.centerYAnchor),
        
            safetyIndexLabel.leadingAnchor.constraint(equalTo: safetyLabel.trailingAnchor, constant: 8),
            safetyIndexLabel.trailingAnchor.constraint(equalTo: safetyPillView.trailingAnchor, constant: -12),
            safetyIndexLabel.centerYAnchor.constraint(equalTo: safetyPillView.centerYAnchor),
            
            //Allergens container/card
            rectangleContainer.topAnchor.constraint(equalTo: safetyRatingLabel.bottomAnchor, constant: 20),
            rectangleContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rectangleContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            allergensIconView.topAnchor.constraint(equalTo: rectangleContainer.topAnchor, constant: 16),
            allergensIconView.leadingAnchor.constraint(equalTo: rectangleContainer.leadingAnchor, constant: 16),
            allergensIconView.widthAnchor.constraint(equalToConstant: 24),
            allergensIconView.heightAnchor.constraint(equalToConstant: 24),
    
            allergensTitleLabel.centerYAnchor.constraint(equalTo: allergensIconView.centerYAnchor),
            allergensTitleLabel.leadingAnchor.constraint(equalTo: allergensIconView.trailingAnchor, constant: 8),
            allergensTitleLabel.trailingAnchor.constraint(equalTo: rectangleContainer.trailingAnchor, constant: -16),
            
            allergensBodyLabel.topAnchor.constraint(equalTo: allergensIconView.bottomAnchor, constant: 12),
            allergensBodyLabel.leadingAnchor.constraint(equalTo: rectangleContainer.leadingAnchor, constant: 16),
            allergensBodyLabel.trailingAnchor.constraint(equalTo: rectangleContainer.trailingAnchor, constant: -16),
            allergensBodyLabel.bottomAnchor.constraint(equalTo: rectangleContainer.bottomAnchor, constant: -16),
            
            //Header inside the card
            ingredientsLabel.topAnchor.constraint(equalTo: ingredientsCardView.topAnchor, constant: 16),
            ingredientsLabel.leadingAnchor.constraint(equalTo: ingredientsCardView.leadingAnchor, constant: 16),
            ingredientsLabel.trailingAnchor.constraint(equalTo: ingredientsCardView.trailingAnchor, constant: -16),
            
            //Card around the list
            ingredientsCardView.topAnchor.constraint(equalTo: rectangleContainer.bottomAnchor, constant: 20),
            ingredientsCardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ingredientsCardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ingredientsCardView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),

            //Table inside the card, under the title
            ingredientsTableView.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor, constant: 8),
            ingredientsTableView.leadingAnchor.constraint(equalTo: ingredientsCardView.leadingAnchor),
            ingredientsTableView.trailingAnchor.constraint(equalTo: ingredientsCardView.trailingAnchor),
            ingredientsTableView.bottomAnchor.constraint(equalTo: ingredientsCardView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Function to update the star icon called by controller
    func updateFavoriteStarIcon(systemName: String) {
        favoriteStarImageView.image = UIImage(systemName: systemName)
    }
    
    //Internal handler for star tap
    @objc func favoriteStarTapped() {
        onFavoriteTapped?()
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
