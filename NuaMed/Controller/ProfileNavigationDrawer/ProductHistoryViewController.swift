import UIKit
import FirebaseAuth

class ProductHistoryViewController: UIViewController {

    private let historyView = ProductHistoryView()
    private var listController: ProductListViewController!

    private var allHistory: [FirebaseService.HistoryItem] = []
    private var displayedHistory: [FirebaseService.HistoryItem] = []

    private var selectedCategory: String = "All Categories"
    private var currentMinSafety: Int = 0
    private var currentMaxSafety: Int = 100

    override func loadView() {
        view = historyView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        view.backgroundColor = .systemBlue
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTap)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        
        // Attach table controller
        listController = ProductListViewController(tableView: historyView.productsTableView)
        listController.onSelectRow = { [weak self] row in
            guard let self = self else { return }

            let vc = ProductInfoViewController(
                name: row.name,
                safetyScore: row.safetyScore,
                pillColor: self.colorFor(score: row.safetyScore),
                ingredientInfoJSON: row.ingredientInfoJSON,
                safetyJSON: row.safetyJSON
            )

            self.navigationController?.pushViewController(vc, animated: true)
        }

        // Category filter
        historyView.categoryDropdown.onCategorySelected = { [weak self] cat in
            self?.selectedCategory = cat
            self?.applyFilters()
        }

        // Safety filter
        historyView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
            guard let self = self else { return }
            self.currentMinSafety = Int(minVal)
            self.currentMaxSafety = Int(maxVal)
            self.applyFilters()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoryFromFirestore()
    }

    // MARK: - Load
    private func loadHistoryFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .failure(let err):
                    print("❌ history fetch error:", err)
                    self.allHistory = []
                    self.displayedHistory = []
                    self.applyFilters()

                case .success(let items):
                    self.allHistory = items
                    self.applyFilters()
                }
            }
        }
    }

    // MARK: - Filtering
    private func applyFilters() {

        var filtered = allHistory

        // Safety filter
        filtered = filtered.filter {
            let score = $0.safetyScore
            return score >= currentMinSafety && score <= currentMaxSafety
        }

        // Category filter
        if selectedCategory != "All Categories" {
            filtered = filtered.filter {
                ($0.category ?? "").lowercased() == selectedCategory.lowercased()
            }
        }

        displayedHistory = filtered

        // Update table rows
        listController.rows = displayedHistory.map {
            ProductRow(
                id: $0.productId,
                name: $0.name,
                safetyScore: $0.safetyScore,
                image: nil,
                ingredientInfoJSON: $0.ingredientInfoJSON,
                safetyJSON: $0.safetyJSON
            )
        }
    }

    // MARK: - Helpers
    private func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
    
    @objc private func backTap() {
        navigationController?.popViewController(animated: true)
    }

}
