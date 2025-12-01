import UIKit

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
        Ingredient(name: "Glycerin", safety: .caution, infoText: "Generally safe but can cause irritation in sensitive skin.")
    ]
    
    private let productName: String
    private let productSafetyScore: Int
    private var isFavorited = false
    
    init(name: String, safetyScore: Int) {
        self.productName = name
        self.productSafetyScore = safetyScore
        super.init(nibName: nil, bundle: nil)
        // hidesBottomBarWhenPushed = true
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
        
        //Handle the tapping on the star
        productInfoView.onFavoriteTapped = { [weak self] in
            guard let self = self else { return }
            
            if self.isFavorited {
                //Remove from favorites
                Favorites.shared.removeProduct(named: self.productName)
                self.isFavorited = false
            }else{
                let favorite = FavoriteProduct(
                    name: self.productName,
                    safetyScore: self.productSafetyScore
                )
                Favorites.shared.addProduct(favorite)
                self.isFavorited = true
            }
            
            //Change the icon from outline to filled
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

