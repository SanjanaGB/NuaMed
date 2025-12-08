import UIKit
import FirebaseAuth

class FavoritesViewController: UIViewController {
    let favoritesView = FavoritesView()
    
    private var items: [FirebaseService.FavoriteItem] = []
    
    private var allFavoritedProducts: [FavoriteProduct] = []
    private var displayedFavoritedProducts: [FavoriteProduct] = []
    
    private var currentMinSafety = 0
    private var currentMaxSafety = 100
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Favorites"
        
        let tableView = favoritesView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
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
        
        loadView()
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
        favoritesView.productsTableView.reloadData()
    }

    override func loadView(){
        view = favoritesView
    }
}
    
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedFavoritedProducts.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = displayedFavoritedProducts[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(name: product.name,
                       safetyIndex: String(product.safetyScore))
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = displayedFavoritedProducts[indexPath.row]
        
        let detailVC = ProductInfoViewController(
            name: item.name,
            safetyScore: item.safetyScore
        )
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath
    ) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.systemGray6
        } else {
            cell.backgroundColor = .white
        }
    }
    
    func filterFavorites(by category: String) {
        print("Selected category:", category)
        // In the future, you can filter `items` by category and reload
    }
    
}
