import UIKit
import FirebaseAuth

enum IngredientSafety {
    case safe
    case unsafe
    case caution
}

struct Ingredient {
    let name: String
    let safety: IngredientSafety
    let infoText: String
}

class ProductInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let productInfoView = ProductInfoView()
    
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
    
    init(name: String, safetyScore: Int) {
        self.productName = name
        self.productSafetyScore = safetyScore
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
        
        //Register custom cell
        productInfoView.ingredientsTableView.register(
            IngredientTableViewCell.self,
            forCellReuseIdentifier: "IngredientCell"
        )
        
        productInfoView.ingredientsTableView.dataSource = self
        productInfoView.ingredientsTableView.delegate = self
        
        productInfoView.configure(
            name: productName,
            safetyScore: productSafetyScore,
            allergens: ["Perfume", "Benzyl Alcohol"]
        )
        
        //Check the status of favoriting
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
        
        //Handle the tapping on the star
        productInfoView.onFavoriteTapped = { [weak self] in
            guard let self = self else { return }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("No logged-in user, cannot sync favorites.")
                return
            }
            
            if self.isFavorited {
                // Remove locally
                Favorites.shared.removeProduct(named: self.productName)
                self.isFavorited = false
                
                // Remove from Firestore
                FirebaseService.shared.removeFavoriteItem(
                    uid: uid,
                    productId: self.productName
                ) { error in
                    if let error = error {
                        print("Failed to remove favorite from Firestore:", error)
                    }
                }
            } else {
                // Add locally
                let favorite = FavoriteProduct(
                    name: self.productName,
                    safetyScore: self.productSafetyScore
                )
                Favorites.shared.addProduct(favorite)
                self.isFavorited = true
                
                // Add to Firestore
                FirebaseService.shared.addFavoriteItem(
                    uid: uid,
                    productId: self.productName,   // use real productId if you have one
                    name: self.productName,
                    category: "General",
                    safetyScore: self.productSafetyScore
                ) { error in
                    if let error = error {
                        print("Failed to save favorite to Firestore:", error)
                    }
                }
            }
            
            // Update star icon after toggle
            self.updateFavoriteStarIcon()
        }
    }
    
    private func updateFavoriteStarIcon() {
        let imageName = isFavorited ? "star.fill" : "star"
        productInfoView.updateFavoriteStarIcon(systemName: imageName)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "IngredientCell",
            for: indexPath
        ) as! IngredientTableViewCell
        
        let ingredient = ingredients[indexPath.row]
        cell.configure(with: ingredient)
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = ingredients[indexPath.row]
        let detailVC = IngredientDetailViewController(ingredient: ingredient)
        present(detailVC, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
