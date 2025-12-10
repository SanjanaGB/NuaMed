import UIKit
import FirebaseAuth

class ProductInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let productInfoView = ProductInfoView()
    //Get the safety index pill color through this variable
    private let pillColor: UIColor
    
    // Temporary hard-coded ingredient list
    private let ingredients: [Ingredient] = [
        Ingredient(name: "Water", safety: .safe, infoText: "Generally considered safe."),
        Ingredient(name: "Sodium Laureth Sulfate", safety: .caution, infoText: "Can cause skin irritation in some individuals."),
        Ingredient(name: "Parabens", safety: .unsafe, infoText: "Linked to hormonal disruptions."),
        Ingredient(name: "Glycerin", safety: .caution, infoText: "Generally safe but can cause irritation in sensitive skin."),
        Ingredient(name: "Glycerin2", safety: .caution, infoText: "Generally safe but can cause irritation in sensitive skin.")
    ]
    
    private let productName: String
    private let productSafetyScore: Int
    private var isFavorited = false
    
    init(name: String, safetyScore: Int, pillColor: UIColor? = nil) {
        self.productName = name
        self.productSafetyScore = safetyScore
        self.pillColor = pillColor ?? .systemGray   //default gray color if no other color passed
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = productInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        let tableView = productInfoView.ingredientsTableView
        tableView.register(IngredientTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 47
        
        productInfoView.configure(
            name: productName,
            safetyScore: productSafetyScore,
            allergens: ["Perfume", "Benzyl Alcohol"],
            pillColor: pillColor
            
        )
        
        // Favorite state from local + Firestore
        isFavorited = Favorites.shared.checkIfFavorited(named: productName)
        updateFavoriteStarIcon()
        
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseService.shared.isFavoriteItem(
                uid: uid,
                productId: productName
            ) { [weak self] isFav in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isFavorited = isFav
                    self.updateFavoriteStarIcon()
                }
            }
        }
        
        // Favorite button handler
        productInfoView.onFavoriteTapped = { [weak self] in
            guard let self = self else { return }
            guard let uid = Auth.auth().currentUser?.uid else {
                print("No logged-in user, cannot sync favorites.")
                return
            }
            
            if self.isFavorited {
                Favorites.shared.removeProduct(named: self.productName)
                self.isFavorited = false
                
                FirebaseService.shared.removeFavoriteItem(
                    uid: uid,
                    productId: self.productName
                ) { error in
                    if let error = error {
                        print("Failed to remove favorite from Firestore:", error)
                    }
                }
            } else {
                let favorite = FavoriteProduct(
                    name: self.productName,
                    safetyScore: self.productSafetyScore
                )
                Favorites.shared.addProduct(favorite)
                self.isFavorited = true
                
                FirebaseService.shared.addFavoriteItem(
                    uid: uid,
                    productId: self.productName,
                    name: self.productName,
                    category: "General",
                    safetyScore: self.productSafetyScore
                ) { error in
                    if let error = error {
                        print("Failed to save favorite to Firestore:", error)
                    }
                }
            }
            
            self.updateFavoriteStarIcon()
        }
    }
    
    private func updateFavoriteStarIcon() {
        let imageName = isFavorited ? "star.fill" : "star"
        productInfoView.updateFavoriteStarIcon(systemName: imageName)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "IngredientCell",
            for: indexPath
        ) as? IngredientTableViewCell else {
            return UITableViewCell()
        }
        
        let ingredient = ingredients[indexPath.row]
        cell.configure(with: ingredient)
        
        cell.onInfoTapped = { [weak self] in
            guard let self = self else { return }
            // Only show if there is detail text
            guard !ingredient.infoText.isEmpty else { return }
            let detailVC = IngredientDetailViewController(ingredient: ingredient)
            self.present(detailVC, animated: true, completion: nil)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = ingredients[indexPath.row]
        let detailVC = IngredientDetailViewController(ingredient: ingredient)
        present(detailVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
