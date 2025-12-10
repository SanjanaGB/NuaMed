import UIKit
import FirebaseAuth

class FavoritesViewController: UIViewController {
    let favoritesView = FavoritesView()
    private var listController: ProductListViewController!
    private var items: [FirebaseService.FavoriteItem] = []
    private var allFavoritedProducts: [FavoriteProduct] = []
    private var displayedFavoritedProducts: [FavoriteProduct] = []
    private var currentMinSafety = 0
    private var currentMaxSafety = 100
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Favorites"
        
//        listController = ProductListTableController(tableView: favoritesView.productsTableView)
        listController = ProductListViewController(tableView: favoritesView.productsTableView)
        listController.onSelectRow = { [weak self] (row: ProductRow) in
            guard let self = self else { return }
            let detailVC = ProductInfoViewController(name: row.name,
                                                     safetyScore: row.safetyScore)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        //Category dropdown menu
        favoritesView.categoryDropdown.onCategorySelected = { [weak self] category in
            self?.filterFavorites(by: category)
        }
        
        favoritesView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
            guard let self = self else { return }
            self.currentMinSafety = Int(minVal.rounded())
            self.currentMaxSafety = Int(maxVal.rounded())
            self.applyFavoritesFilters()
        }
    }
    
    //Get the products from the Favorites file
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            allFavoritedProducts = []
            displayedFavoritedProducts = []
            favoritesView.productsTableView.reloadData()
            return
        }
        
        FirebaseService.shared.fetchFavoriteItems(forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Failed to fetch favorites from Firestore:", error)
                    self?.allFavoritedProducts = []
                    self?.displayedFavoritedProducts = []
                    self?.favoritesView.productsTableView.reloadData()
                    
                case .success(let fetchedItems):
                    // Convert Firestore model -> your UI model
                    self?.allFavoritedProducts = fetchedItems.map {
                        FavoriteProduct(name: $0.name, safetyScore: $0.safetyScore)
                    }
                    
                    // Apply range filter immediately
                    self?.applyFavoritesFilters()
                }
            }
        }
    }
    
    func userFavorited(productId: String, name: String, category: String, safetyScore: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseService.shared.addFavoriteItem(
            uid: uid,
            productId: productId,
            name: name,
            category: category,
            safetyScore: safetyScore
        ) { error in
            if let error = error {
                print("Error adding favorite item:", error)
            }
        }
    }
    
    func userUnfavorited(productId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseService.shared.removeFavoriteItem(
            uid: uid,
            productId: productId
        ) { error in
            if let error = error {
                print("Error removing favorite item:", error)
            }
        }
    }
    
    private func applyFavoritesFilters() {
        displayedFavoritedProducts = allFavoritedProducts.filter { product in
            let s = product.safetyScore
            return s >= currentMinSafety && s <= currentMaxSafety
        }
        
        listController.rows = displayedFavoritedProducts.map { product in
            ProductRow(
                id: product.name,
                name: product.name,
                safetyScore: product.safetyScore,
                image: nil
            )
        }
    }

    override func loadView(){
        view = favoritesView
    }
    
    private func filterFavorites(by category: String) {
        print("Selected category:", category)
        // Later: actually filter allFavoritedProducts by category and call applyFavoritesFilters()
    }
}
