import UIKit
import FirebaseAuth

class FavoritesViewController: UIViewController {

    let favoritesView = FavoritesView()
    private var listController: ProductListViewController!

    private var allFavoritedProducts: [FavoriteProduct] = []
    private var displayedFavoritedProducts: [FavoriteProduct] = []

    private var selectedCategory: String = "All"
    private var currentMinSafety = 0
    private var currentMaxSafety = 100

    override func loadView() {
        view = favoritesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorites"
        view.backgroundColor = .systemBlue

        // TABLE CONTROLLER
        listController = ProductListViewController(tableView: favoritesView.productsTableView)
        listController.onSelectRow = { [weak self] row in
            guard let self = self else { return }

            let detailVC = ProductInfoViewController(
                name: row.name,
                safetyScore: row.safetyScore,
                pillColor: self.colorFor(score: row.safetyScore),
                ingredientInfoJSON: row.ingredientInfoJSON,
                safetyJSON: row.safetyJSON
            )
            self.navigationController?.pushViewController(detailVC, animated: true)
        }

        // CATEGORY PICKER
        favoritesView.categoryDropdown.onCategorySelected = { [weak self] category in
            guard let self = self else { return }

            // Normalize category right away
            if category == "All Categories" {
                self.selectedCategory = "All"
            } else {
                self.selectedCategory = category
            }
            
            self.applyFavoritesFilters()
        }


        // SAFETY SLIDER
        favoritesView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
            guard let self = self else { return }
            self.currentMinSafety = Int(minVal)
            self.currentMaxSafety = Int(maxVal)
            self.applyFavoritesFilters()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoritesFromFirestore()
    }

    // MARK: - FIRESTORE LOAD
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
                case .failure(let err):
                    print("❌ Favorites fetch error:", err)
                    self.allFavoritedProducts = []

                case .success(let items):
                    self.allFavoritedProducts = items.map {
                        FavoriteProduct(
                            name: $0.name,
                            safetyScore: $0.safetyScore,
                            category: $0.category.isEmpty ? "General" : $0.category,
                            ingredientInfoJSON: $0.ingredientInfoJSON,
                            safetyJSON: $0.safetyJSON
                        )
                    }
                }

                self.applyFavoritesFilters()
            }
        }
    }

    // MARK: - FILTER SYSTEM
    // MARK: - FILTER SYSTEM
    private func applyFavoritesFilters() {

        // Normalize category
        let normalizedCategory =
            (selectedCategory == "All Categories" || selectedCategory == "All")
            ? "All"
            : selectedCategory

        // 1️⃣ Safety filter
        var filtered = allFavoritedProducts.filter {
            ($0.safetyScore >= currentMinSafety) && ($0.safetyScore <= currentMaxSafety)
        }

        // 2️⃣ Category filter
        if normalizedCategory != "All" {
            filtered = filtered.filter {
                $0.category.lowercased() == normalizedCategory.lowercased()
            }
        }

        displayedFavoritedProducts = filtered

        // UPDATE TABLE
        listController.rows = displayedFavoritedProducts.map {
            ProductRow(
                id: $0.name,
                name: $0.name,
                safetyScore: $0.safetyScore,
                image: nil,
                ingredientInfoJSON: $0.ingredientInfoJSON,
                safetyJSON: $0.safetyJSON
            )
        }
    }

    // MARK: - COLOR CODE
    private func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
}
