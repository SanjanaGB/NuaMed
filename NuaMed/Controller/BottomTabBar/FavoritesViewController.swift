import UIKit
import FirebaseAuth

class FavoritesViewController: UIViewController {

    let favoritesView = FavoritesView()
    private var listController: ProductListViewController!

    // Firestore → UI model
    private var allFavoritedProducts: [FavoriteProduct] = []
    private var displayedFavoritedProducts: [FavoriteProduct] = []

    private var currentMinSafety = 0
    private var currentMaxSafety = 100

    override func loadView() {
        view = favoritesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemBlue
        title = "Favorites"

        // Table controller
        listController = ProductListViewController(tableView: favoritesView.productsTableView)
        listController.onSelectRow = { [weak self] row in
            guard let self = self else { return }

            let detailVC = ProductInfoViewController(
                name: row.name,
                safetyScore: row.safetyScore,
                pillColor: self.colorFor(score: row.safetyScore),
                ingredientInfoJSON: row.ingredientInfoJSON,   // will update later
                safetyJSON: row.safetyJSON
            )

            self.navigationController?.pushViewController(detailVC, animated: true)
        }

        // Category dropdown
        favoritesView.categoryDropdown.onCategorySelected = { [weak self] category in
            self?.filterFavorites(by: category)
        }

        // Safety slider
        favoritesView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
            guard let self = self else { return }
            self.currentMinSafety = Int(minVal.rounded())
            self.currentMaxSafety = Int(maxVal.rounded())
            self.applyFavoritesFilters()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoritesFromFirestore()
    }

    // MARK: - Load from Firestore
    private func loadFavoritesFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else {
            allFavoritedProducts = []
            displayedFavoritedProducts = []
            favoritesView.productsTableView.reloadData()
            return
        }

        FirebaseService.shared.fetchFavoriteItems(forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    print("❌ Failed to fetch favorites:", error)
                    self.allFavoritedProducts = []
                    self.displayedFavoritedProducts = []
                    self.favoritesView.productsTableView.reloadData()

                case .success(let items):
                    self.allFavoritedProducts = items.map {
                        FavoriteProduct(
                            name: $0.name,
                            safetyScore: $0.safetyScore,
                            ingredientInfoJSON: $0.ingredientInfoJSON,
                                    safetyJSON: $0.safetyJSON
                        )
                    }

                    self.applyFavoritesFilters()
                }
            }
        }
    }

    // MARK: - Filtering
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
                image: nil,
                ingredientInfoJSON: product.ingredientInfoJSON,
                safetyJSON: product.safetyJSON
            )
        }
    }

    // MARK: - Category filtering placeholder
    private func filterFavorites(by category: String) {
        print("Selected category:", category)
        // Later you will integrate category matching.
        applyFavoritesFilters()
    }

    // MARK: - Helpers
    private func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
}
